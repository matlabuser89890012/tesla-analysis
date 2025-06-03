#!/bin/bash

# Create model-store directory if it doesn't exist
mkdir -p model-store

# Train the model first if model doesn't exist
if [ ! -f "model-store/model.pt" ]; then
    echo "Training model..."
    python train.py
fi

# Create the model archive using torch-model-archiver
torch-model-archiver --model-name tsla-model \
  --version 1.0 \
  --model-file model.py \
  --serialized-file model-store/model.pt \
  --handler handler.py \
  --extra-files model-store/index_to_name.json \
  --export-path model-store

# Verify the .mar file was created
if [ -f "model-store/tsla-model.mar" ]; then
    echo "Successfully created model archive: model-store/tsla-model.mar"
else
    echo "Failed to create model archive"
    exit 1
fi

echo "To start TorchServe, run: torchserve --start --model-store model-store --models tsla=tsla-model.mar"
echo "To test the model, use: curl -X POST http://localhost:8080/predictions/tsla -T test_sample.json"
