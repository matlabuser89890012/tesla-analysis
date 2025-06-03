"""
Training script for Tesla stock prediction model.
"""
import os
import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
import pandas as pd
import yfinance as yf
from datetime import datetime, timedelta
from sklearn.preprocessing import MinMaxScaler
from torch.utils.data import TensorDataset, DataLoader
from model import TeslaPredictionModel

# Set random seed for reproducibility
torch.manual_seed(42)
np.random.seed(42)

def create_sequences(data, seq_length):
    """
    Create sequences of data for time series prediction.
    
    Args:
        data (np.ndarray): Input data array
        seq_length (int): Sequence length (window size)
        
    Returns:
        tuple: (X, y) where X is sequences and y is targets
    """
    xs, ys = [], []
    for i in range(len(data) - seq_length):
        x = data[i:i+seq_length]
        y = data[i+seq_length, 3]  # Target is the next closing price
        xs.append(x)
        ys.append(y)
    return np.array(xs), np.array(ys)

def train_model(epochs=50, batch_size=32, seq_length=20, learning_rate=0.001):
    """
    Train the Tesla stock prediction model.
    
    Args:
        epochs (int): Number of training epochs
        batch_size (int): Batch size for training
        seq_length (int): Sequence length for LSTM
        learning_rate (float): Learning rate for optimizer
        
    Returns:
        TeslaPredictionModel: Trained model
    """
    # Download Tesla stock data
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5*365)  # 5 years of data
    
    print(f"Downloading Tesla stock data from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")
    df = yf.download('TSLA', start=start_date, end=end_date)
    
    if df.empty:
        raise ValueError("Failed to download Tesla stock data")
    
    print(f"Downloaded {len(df)} days of data")
    
    # Keep only OHLCV columns
    data = df[['Open', 'High', 'Low', 'Close', 'Volume']].values
    
    # Normalize data
    scaler = MinMaxScaler(feature_range=(0, 1))
    data_normalized = scaler.fit_transform(data)
    
    # Create sequences
    X, y = create_sequences(data_normalized, seq_length)
    
    # Split into train and validation sets (80/20)
    train_size = int(len(X) * 0.8)
    X_train, X_val = X[:train_size], X[train_size:]
    y_train, y_val = y[:train_size], y[train_size:]
    
    # Convert to PyTorch tensors
    X_train = torch.FloatTensor(X_train)
    y_train = torch.FloatTensor(y_train).view(-1, 1)
    X_val = torch.FloatTensor(X_val)
    y_val = torch.FloatTensor(y_val).view(-1, 1)
    
    # Create DataLoader
    train_dataset = TensorDataset(X_train, y_train)
    val_dataset = TensorDataset(X_val, y_val)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
    
    # Initialize model, loss function, and optimizer
    input_dim = X_train.shape[2]  # Number of features (OHLCV)
    model = TeslaPredictionModel(input_dim=input_dim)
    
    # Use GPU if available
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")
    model.to(device)
    
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    
    # Training loop
    for epoch in range(epochs):
        model.train()
        train_loss = 0
        
        for batch_X, batch_y in train_loader:
            batch_X, batch_y = batch_X.to(device), batch_y.to(device)
            
            # Forward pass
            outputs = model(batch_X)
            loss = criterion(outputs, batch_y)
            
            # Backward pass and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
        
        # Validation
        model.eval()
        val_loss = 0
        
        with torch.no_grad():
            for batch_X, batch_y in val_loader:
                batch_X, batch_y = batch_X.to(device), batch_y.to(device)
                outputs = model(batch_X)
                loss = criterion(outputs, batch_y)
                val_loss += loss.item()
        
        print(f'Epoch {epoch+1}/{epochs}, Train Loss: {train_loss/len(train_loader):.4f}, Val Loss: {val_loss/len(val_loader):.4f}')
    
    # Save the model
    os.makedirs('model-store', exist_ok=True)
    torch.save(model.state_dict(), 'model-store/model.pt')
    
    print("Model saved successfully")
    return model

if __name__ == "__main__":
    train_model()
    
    # Create additional files needed for TorchServe
    # index_to_name.json
    with open('model-store/index_to_name.json', 'w') as f:
        json.dump({"0": "price"}, f)
    
    print("Created index_to_name.json")
    print("Now run torch-model-archiver to create the model archive (.mar) file")
