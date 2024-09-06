# Workshop Overview

Welcome to the instruction guide for the Contoso Chat workshop. Learn how to build, evaluate, deploy, and test, a custom RAG-based retail copilot **code-first** on Azure AI.

## 1. Application Scenario

**Contoso Outdoors** is an enterprise retailer with an online store selling hiking and camping equipment to adventure-seeking customers. **Contoso Chat** is the custom copilot (AI chatbot) that answers customer questions about the product catalog with relevant responses and recommendations based on their prior purchase history.

![Contoso Web](./img/00-app-scenario-ai.png)

## 2. Application Architecture

The Contoso Chat implementation uses a **Retrieval Augmented Generation** pattern to ground responses in the retailer's product and customer data. This is the high-level architecture, showing the key resources that we will be provisioning on Azure AI, for this workshop.

![RAG](./img/architecture-diagram-contoso-retail-aistudio.png)


## 3. Workshop Format

The workshop supports two delivery formats:

1. [**Instructor Guided**](./skillable-getstarted-deploy.md). These are 75-minute sessions offered on the Microsoft AI Tour (2024-2025). They use a pre-provisioned Azure subscription with the Skillable platform.

1. [**Self Guided**](./skillable-getstarted.md). These is for self-paced learning (home or community). You will need your own Azure subscription and will provision the infrastructure yourself.


## 4. Pre-Requisites

**TODO**

## 5. Next Steps

It's time to get started with the workshop. 
- If you are a self-guided learner, or a workshop organizer, start with [Part 0: Pre-Provisioning](./0-Preprovision.md) to provision the Azure subscription with required infrastructure.
- If you are an AI Tour lab attendee, go directly to [Part 1: Getting Started](1-GetStarted.md) since you will be using a pre-provisioned Azure subscription.