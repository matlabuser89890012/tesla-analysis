import hashlib
import hmac

from fastapi import FastAPI, HTTPException, Request

app = FastAPI()

WEBHOOK_SECRET = "your_webhook_secret"

@app.post("/github/webhook")
async def handle_webhook(request: Request):
    # Verify the webhook signature
    signature = request.headers.get("X-Hub-Signature-256")
    if not signature:
        raise HTTPException(status_code=400, detail="Missing signature")

    body = await request.body()
    computed_signature = "sha256=" + hmac.new(
        WEBHOOK_SECRET.encode(), body, hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(computed_signature, signature):
        raise HTTPException(status_code=400, detail="Invalid signature")

    # Process the webhook payload
    payload = await request.json()
    print("Received webhook event:", payload)

    return {"message": "Webhook received successfully"}
