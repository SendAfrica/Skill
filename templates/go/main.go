package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"

	sendafrica "github.com/SendAfrica/GO-SDK"
)

func main() {
	apiKey := os.Getenv("SENDAFRICA_API_KEY")
	if apiKey == "" {
		log.Fatal("Set SENDAFRICA_API_KEY in your environment first.")
	}

	client := sendafrica.NewClient(apiKey,
		sendafrica.WithBaseURL("https://api.sendafrica.online/v1"),
		sendafrica.WithMaxRetries(3),
	)

	checkBalance(client)
	analyzeMessage()
	messageID := sendFirstSMS(client)
	fmt.Printf("\nTrack delivery: GET /v1/sms/logs?search=%s\n", messageID)
}

func checkBalance(client *sendafrica.Client) {
	balance, err := client.Credits.Balance(context.Background())
	if err != nil {
		handleError(err)
		return
	}
	fmt.Printf("Balance: %d credits on account %s\n", balance.Balance, balance.AccountID)
}

func analyzeMessage() {
	info := sendafrica.GetSMSPartInfo("Hello from SendAfrica! Your order is ready.")
	fmt.Printf("Encoding: %s, Parts: %d, Credits: %d\n", info.Encoding, info.Parts, info.CreditsRequired)
}

func sendFirstSMS(client *sendafrica.Client) string {
	result, err := client.SMS.Send(context.Background(), sendafrica.SendSMSRequest{
		To:      "0712345678",
		Message: "Hello from SendAfrica! Your order is ready.",
		Sender:  "MyBrand",
	}, sendafrica.RequestOptions{IdempotencyKey: "order-1234"})
	if err != nil {
		handleError(err)
		return ""
	}
	fmt.Printf("Sent: %s — %s — %d credit(s)\n", result.MessageID, result.Status, result.CreditsUsed)
	return result.MessageID
}

func handleError(err error) {
	var apiErr *sendafrica.APIError
	if errors.As(err, &apiErr) {
		if apiErr.IsInsufficientCredits() {
			fmt.Println("Not enough credits — top up at https://app.sendafrica.online")
			return
		}
		if apiErr.IsRateLimited() {
			fmt.Printf("Rate limited, retry after %v\n", apiErr.RetryAfter)
			return
		}
		if apiErr.IsUnauthorized() {
			fmt.Println("Check your API key at https://app.sendafrica.online/settings/api-keys")
			return
		}
		log.Fatalf("API error: %s (request_id=%s)", apiErr.Message, apiErr.RequestID)
	}
	if errors.Is(err, sendafrica.ErrInvalidPhone) {
		fmt.Println("The destination number is not a valid Tanzania mobile number.")
		return
	}
	log.Fatal(err)
}
