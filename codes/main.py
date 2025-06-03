# Tesla Stock Analysis Dashboard - Interactive web application

import yfinance as yf
import plotly.graph_objs as go
from plotly.subplots import make_subplots
import pandas as pd
import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import datetime as dt
import numpy as np
from fastapi import FastAPI
import uvicorn

# Initialize the Dash app with a Bootstrap theme
app = dash.Dash(__name__, 
                external_stylesheets=[dbc.themes.DARKLY],
                meta_tags=[{'name': 'viewport', 'content': 'width=device-width, initial-scale=1'}])

# For gunicorn deployment
server = app.server

# FastAPI instance
api = FastAPI()

# Default stocks to track
DEFAULT_STOCKS = ['TSLA', 'AVGO', 'NFLX', 'MSFT', 'AAPL', 'NVDA', 'GOOGL', 'META', 'AMZN']

# Time periods for analysis
PERIODS = ['1d', '5d', '1mo', '3mo', '6mo', '1y', '2y', '5y', 'max']
INTERVALS = ['1m', '2m', '5m', '15m', '30m', '60m', '90m', '1h', '1d', '5d', '1wk', '1mo', '3mo']

# Function to fetch stock data
def fetch_data(symbols, period='1mo', interval='1d'):
    if isinstance(symbols, str):
        symbols = [symbols]
    
    all_data = {}
    for symbol in symbols:
        try:
            data = yf.download(tickers=symbol, period=period, interval=interval, progress=False)
            if not data.empty:
                all_data[symbol] = data
        except Exception as e:
            print(f"Error fetching {symbol}: {e}")
    
    return all_data

# App layout with Bootstrap components
app.layout = dbc.Container([
    dbc.Row([
        dbc.Col([
            html.H1("Tesla & Tech Stocks Analysis Dashboard", className="text-center mb-4"),
            html.H5("Real-time market data and interactive analysis", className="text-center text-muted mb-5"),
        ], width=12)
    ]),
    
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Select Stocks & Timeframe"),
                dbc.CardBody([
                    dbc.Label("Stock Symbols (comma-separated)"),
                    dbc.Input(id="stock-input", value=",".join(DEFAULT_STOCKS), type="text"),
                    html.Br(),
                    
                    dbc.Row([
                        dbc.Col([
                            dbc.Label("Time Period"),
                            dbc.Select(id="period-select", 
                                    options=[{"label": p, "value": p} for p in PERIODS],
                                    value="1mo")
                        ], width=6),
                        dbc.Col([
                            dbc.Label("Interval"),
                            dbc.Select(id="interval-select", 
                                    options=[{"label": i, "value": i} for i in INTERVALS],
                                    value="1d")
                        ], width=6)
                    ]),
                    
                    html.Br(),
                    dbc.Button("Update Dashboard", id="submit-button", color="primary", className="mr-2")
                ])
            ], className="mb-4"),
            
            dbc.Card([
                dbc.CardHeader("Tesla Performance Stats"),
                dbc.CardBody(id="tesla-stats")
            ])
        ], width=3),
        
        dbc.Col([
            dbc.Tabs([
                dbc.Tab(dcc.Graph(id="stock-price-graph"), label="Price Chart"),
                dbc.Tab(dcc.Graph(id="returns-graph"), label="% Returns"),
                dbc.Tab(dcc.Graph(id="volume-graph"), label="Volume")
            ])
        ], width=9)
    ]),
    
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Correlation Heatmap"),
                dbc.CardBody([
                    dcc.Graph(id="correlation-graph")
                ])
            ])
        ], width=6),
        
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Performance Comparison"),
                dbc.CardBody([
                    dcc.Graph(id="performance-graph")
                ])
            ])
        ], width=6)
    ], className="mt-4"),
    
    dbc.Row([
        dbc.Col([
            html.Div([
                html.P("Data provided by Yahoo Finance API | Dashboard updates every 60 seconds", 
                      className="text-center text-muted"),
                html.P(id="last-update-time", className="text-center")
            ], className="mt-4 mb-2")
        ], width=12)
    ]),
    
    dcc.Interval(id="interval-component", interval=60*1000, n_intervals=0)  # Update every 60 seconds
    
], fluid=True)

# Callback to update all charts
@app.callback(
    [Output("stock-price-graph", "figure"),
     Output("returns-graph", "figure"),
     Output("volume-graph", "figure"),
     Output("correlation-graph", "figure"),
     Output("performance-graph", "figure"),
     Output("tesla-stats", "children"),
     Output("last-update-time", "children")],
    [Input("submit-button", "n_clicks"),
     Input("interval-component", "n_intervals")],
    [dash.dependencies.State("stock-input", "value"),
     dash.dependencies.State("period-select", "value"),
     dash.dependencies.State("interval-select", "value")]
)
def update_dashboard(n_clicks, n_intervals, stock_input, period, interval):
    # Parse stock symbols
    symbols = [s.strip().upper() for s in stock_input.split(",") if s.strip()]
    if not symbols:
        symbols = DEFAULT_STOCKS
    
    # Always ensure TSLA is included for Tesla stats
    if "TSLA" not in symbols:
        symbols = ["TSLA"] + symbols
    
    # Fetch data
    data = fetch_data(symbols, period, interval)
    
    # Price Chart
    price_fig = make_subplots(rows=1, cols=1, shared_xaxes=True)
    
    for symbol in symbols:
        if symbol in data:
            df = data[symbol]
            price_fig.add_trace(go.Scatter(
                x=df.index, 
                y=df['Close'], 
                mode='lines', 
                name=symbol
            ))
    
    price_fig.update_layout(
        title="Stock Price Evolution",
        xaxis_title="Date",
        yaxis_title="Price ($)",
        legend_title="Stocks",
        height=500,
        margin=dict(l=40, r=40, t=40, b=40),
        hovermode="x unified"
    )
    
    # Returns Chart
    returns_fig = go.Figure()
    
    for symbol in symbols:
        if symbol in data:
            df = data[symbol].copy()
            if not df.empty:
                df['Return'] = df['Close'].pct_change().fillna(0).cumsum() * 100
                returns_fig.add_trace(go.Scatter(
                    x=df.index, 
                    y=df['Return'], 
                    mode='lines', 
                    name=symbol
                ))
    
    returns_fig.update_layout(
        title="Cumulative % Returns",
        xaxis_title="Date",
        yaxis_title="Return (%)",
        legend_title="Stocks",
        height=500,
        margin=dict(l=40, r=40, t=40, b=40),
        hovermode="x unified"
    )
    
    # Volume Chart
    volume_fig = go.Figure()
    
    for symbol in symbols:
        if symbol in data:
            df = data[symbol]
            if not df.empty and 'Volume' in df.columns:
                volume_fig.add_trace(go.Bar(
                    x=df.index, 
                    y=df['Volume'], 
                    name=symbol
                ))
    
    volume_fig.update_layout(
        title="Trading Volume",
        xaxis_title="Date",
        yaxis_title="Volume",
        legend_title="Stocks",
        height=500,
        margin=dict(l=40, r=40, t=40, b=40),
        hovermode="x unified"
    )
    
    # Correlation Heatmap
    corr_df = pd.DataFrame()
    
    for symbol in symbols:
        if symbol in data and not data[symbol].empty:
            corr_df[symbol] = data[symbol]['Close']
    
    corr_matrix = corr_df.corr()
    
    corr_fig = go.Figure(data=go.Heatmap(
        z=corr_matrix.values,
        x=corr_matrix.index,
        y=corr_matrix.columns,
        colorscale='Viridis',
        colorbar=dict(title="Correlation"),
        hoverongaps=False
    ))
    
    corr_fig.update_layout(
        title="Price Correlation Matrix",
        height=400,
        margin=dict(l=40, r=40, t=40, b=40)
    )
    
    # Performance Comparison
    perf_fig = go.Figure()
    
    # Calculate normalized performance (starting from 100)
    for symbol in symbols:
        if symbol in data and not data[symbol].empty:
            df = data[symbol].copy()
            first_close = df['Close'].iloc[0]
            df['Normalized'] = (df['Close'] / first_close) * 100
            perf_fig.add_trace(go.Scatter(
                x=df.index, 
                y=df['Normalized'], 
                mode='lines', 
                name=symbol
            ))
    
    perf_fig.update_layout(
        title="Normalized Performance (Base=100)",
        xaxis_title="Date",
        yaxis_title="Performance",
        legend_title="Stocks",
        height=400,
        margin=dict(l=40, r=40, t=40, b=40),
        hovermode="x unified"
    )
    
    # Tesla stats
    tesla_stats = []
    
    if "TSLA" in data and not data["TSLA"].empty:
        df = data["TSLA"]
        current_price = df['Close'].iloc[-1]
        prev_price = df['Close'].iloc[-2] if len(df) > 1 else df['Close'].iloc[0]
        day_change = ((current_price - prev_price) / prev_price) * 100
        day_color = "success" if day_change >= 0 else "danger"
        
        # Get Tesla info
        try:
            tesla_info = yf.Ticker("TSLA").info
            market_cap = tesla_info.get('marketCap', 0) / 1e9  # Convert to billions
            pe_ratio = tesla_info.get('trailingPE', 0)
            avg_volume = tesla_info.get('averageVolume', 0) / 1e6  # Convert to millions
        except:
            market_cap = 0
            pe_ratio = 0
            avg_volume = 0
        
        # Build stats cards
        tesla_stats = [
            html.H3(f"${current_price:.2f}", className="text-center"),
            html.H5([
                f"{day_change:.2f}% ", 
                html.I(className=f"fas fa-arrow-{'up' if day_change >= 0 else 'down'}")
            ], className=f"text-{day_color} text-center mb-4"),
            
            dbc.Row([
                dbc.Col([
                    html.P("Market Cap", className="mb-0 text-muted"),
                    html.H6(f"${market_cap:.1f}B")
                ], width=6),
                dbc.Col([
                    html.P("P/E Ratio", className="mb-0 text-muted"),
                    html.H6(f"{pe_ratio:.2f}")
                ], width=6)
            ], className="mb-3"),
            
            dbc.Row([
                dbc.Col([
                    html.P("52w High", className="mb-0 text-muted"),
                    html.H6(f"${df['High'].max():.2f}")
                ], width=6),
                dbc.Col([
                    html.P("52w Low", className="mb-0 text-muted"),
                    html.H6(f"${df['Low'].min():.2f}")
                ], width=6)
            ], className="mb-3"),
            
            dbc.Row([
                dbc.Col([
                    html.P("Avg Volume", className="mb-0 text-muted"),
                    html.H6(f"{avg_volume:.1f}M")
                ], width=12)
            ])
        ]
    
    # Update time
    update_time = f"Last updated: {dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    
    return price_fig, returns_fig, volume_fig, corr_fig, perf_fig, tesla_stats, update_time

# FastAPI route
@api.get("/")
def read_root():
    return {"message": "Tesla Stock Analysis API"}

if __name__ == '__main__':
    # For local development
    app.run_server(debug=True, host='0.0.0.0', port=8050)
    #uvicorn.run("codes.main:app", host="0.0.0.0", port=8050, reload=True)
