import os
import sys
import torch
import time
from datetime import datetime
 
try:
    # Try to get the environment variable (this is not required to test GPU)
    aws_region = os.getenv('AWS_REGION')
    print("Value AWS_REGION successfully read from OS")
    if not aws_region:
        raise ValueError("Environment variable 'AWS_REGION' is not set.")
except ValueError as e:
    # Handle the error
    print(f"Error: {e}")
    # Set a default value
    print("Setting AWS_REGION manually")
    aws_region = "ap-southeast-2"
 
if torch.cuda.is_available():
    print("*** GPU detected!  Using CUDA.")
else:
    print("*** GPU NOT detected.  Using CPU.")
 
print("Starting Nap....")
time.sleep(120)
print("Nap completed")