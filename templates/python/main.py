import os

from sendafrica import SendAfrica
from sendafrica.exceptions import (
    AuthenticationError,
    InsufficientCreditsError,
    InvalidPhoneError,
    RateLimitError,
    SendAfricaError,
)

API_KEY = os.environ.get("SENDAFRICA_API_KEY", "")
if not API_KEY:
    raise SystemExit("Set SENDAFRICA_API_KEY in your environment first.")

client = SendAfrica(api_key=API_KEY)


def check_balance() -> None:
    balance = client.credits.balance()
    print(f"Balance: {balance.balance} credits on account {balance.account_id}")


def send_first_sms() -> str:
    result = client.sms.send(
        to="0712345678",
        message="Hello from SendAfrica! Your order is ready.",
        sender="MyBrand",
    )
    print(f"Sent: {result.message_id} — {result.status} — {result.credits_used} credit(s)")
    return result.message_id


def analyze_message() -> None:
    analysis = client.sms.analyze("Hello from SendAfrica! Your order is ready.")
    print(f"Encoding: {analysis.encoding}, Parts: {analysis.parts}, Credits: {analysis.credits}")


def main() -> None:
    check_balance()
    analyze_message()
    message_id = send_first_sms()
    print(f"\nTrack delivery: GET /v1/sms/logs?search={message_id}")


if __name__ == "__main__":
    try:
        main()
    except InvalidPhoneError:
        print("The destination number is not a valid Tanzania mobile number.")
    except InsufficientCreditsError:
        print("Not enough credits — top up at https://app.sendafrica.online")
    except RateLimitError as exc:
        print(f"Rate limited — wait {exc.retry_after}s")
    except AuthenticationError:
        print("Check your API key at https://app.sendafrica.online/settings/api-keys")
    except SendAfricaError as exc:
        print(f"API error: {exc.message} (request_id={exc.request_id})")
