"""
TorchServe handler for Tesla stock prediction model.
"""
import json
import logging
import os
import numpy as np
import torch
from ts.torch_handler.base_handler import BaseHandler

logger = logging.getLogger(__name__)

class TeslaModelHandler(BaseHandler):
    """
    Custom handler for Tesla stock prediction model.
    """
    def __init__(self):
        super(TeslaModelHandler, self).__init__()
        self.initialized = False
        
    def initialize(self, context):
        """
        Initialize model. This will be called during model loading time
        
        Args:
            context (context): It is a JSON Object containing information
            pertaining to the model artifacts parameters.
        """
        self.manifest = context.manifest
        
        properties = context.system_properties
        model_dir = properties.get("model_dir")
        self.device = torch.device("cuda:" + str(properties.get("gpu_id")) if torch.cuda.is_available() else "cpu")
        
        # Load model
        serialized_file = self.manifest['model']['serializedFile']
        model_pt_path = os.path.join(model_dir, serialized_file)
        
        if not os.path.isfile(model_pt_path):
            raise RuntimeError("Missing model file")
        
        # Load the model definition first to get the class
        from model import TeslaPredictionModel
        
        # Load model state dict
        state_dict = torch.load(model_pt_path, map_location=self.device)
        
        # Create a model instance and load the state dict
        self.model = TeslaPredictionModel()
        self.model.load_state_dict(state_dict)
        self.model.to(self.device)
        self.model.eval()
        
        logger.debug('Model loaded successfully')
        self.initialized = True
        
    def preprocess(self, data):
        """
        Transform raw input into model input data.
        
        Args:
            data (list): List of input data items from the request
            
        Returns:
            torch.Tensor: Preprocessed model input data
        """
        # Convert request data to PyTorch tensor
        input_data = []
        
        for item in data:
            # Get request body
            body = item.get("body")
            if isinstance(body, (bytes, bytearray)):
                body = body.decode('utf-8')
                
            # Parse JSON input
            json_body = json.loads(body)
            
            # Extract features: expects a sequence of OHLCV data
            # Format: { "features": [[open, high, low, close, volume], ...] }
            features = json_body.get("features", [])
            
            # Convert to numpy, then torch tensor
            features_array = np.array(features, dtype=np.float32)
            
            # Make sure we have the right dimensions [batch_size=1, seq_len, features]
            if len(features_array.shape) == 2:  # [seq_len, features]
                features_array = np.expand_dims(features_array, 0)  # Add batch dimension
                
            input_data.append(torch.from_numpy(features_array))
            
        # Concatenate all batches if multiple requests
        input_tensor = torch.cat(input_data, dim=0).to(self.device)
        return input_tensor
        
    def inference(self, data):
        """
        Run model inference on preprocessed data.
        
        Args:
            data (torch.Tensor): Preprocessed input data
            
        Returns:
            torch.Tensor: Model predictions
        """
        with torch.no_grad():
            output = self.model(data)
        return output
        
    def postprocess(self, inference_output):
        """
        Process model output into a format for the response.
        
        Args:
            inference_output (torch.Tensor): Raw model output
            
        Returns:
            list: Processed output for the response
        """
        # Convert from torch tensor to numpy to list
        predictions = inference_output.cpu().numpy().tolist()
        
        # Format the response
        response = []
        for pred in predictions:
            # For a simple regression model, pred would be a single value
            # For classification, you would add class names from index_to_name.json
            response.append({"prediction": pred})
            
        return response
