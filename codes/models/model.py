"""
Simple LSTM model for Tesla stock prediction.
"""
import torch
import torch.nn as nn

class TeslaPredictionModel(nn.Module):
    """
    LSTM-based model for predicting Tesla stock price movements.
    
    Args:
        input_dim (int): Number of input features
        hidden_dim (int): Dimension of hidden layers
        num_layers (int): Number of LSTM layers
        output_dim (int): Number of output features (usually 1 for regression)
        dropout (float): Dropout rate
    """
    def __init__(self, input_dim=5, hidden_dim=64, num_layers=2, output_dim=1, dropout=0.2):
        super(TeslaPredictionModel, self).__init__()
        
        self.hidden_dim = hidden_dim
        self.num_layers = num_layers
        
        # LSTM layers
        self.lstm = nn.LSTM(
            input_size=input_dim,
            hidden_size=hidden_dim,
            num_layers=num_layers,
            batch_first=True,
            dropout=dropout
        )
        
        # Fully connected output layer
        self.fc = nn.Linear(hidden_dim, output_dim)
    
    def forward(self, x):
        """
        Forward pass through the network.
        
        Args:
            x (torch.Tensor): Input tensor of shape [batch_size, seq_len, input_dim]
            
        Returns:
            torch.Tensor: Output predictions of shape [batch_size, output_dim]
        """
        # Initialize hidden and cell states
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_dim).to(x.device)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_dim).to(x.device)
        
        # Forward propagate LSTM
        out, _ = self.lstm(x, (h0, c0))
        
        # Get the last time step output
        out = self.fc(out[:, -1, :])
        
        return out

def get_model(pretrained=False, **kwargs):
    """
    Factory function to create and optionally load a pretrained model.
    
    Args:
        pretrained (bool): Whether to load pretrained weights
        **kwargs: Additional arguments to pass to the model constructor
    
    Returns:
        TeslaPredictionModel: The instantiated model
    """
    model = TeslaPredictionModel(**kwargs)
    
    if pretrained:
        try:
            model.load_state_dict(torch.load('model_weights.pth'))
            print("Loaded pretrained weights")
        except Exception as e:
            print(f"Failed to load pretrained weights: {str(e)}")
    
    return model
