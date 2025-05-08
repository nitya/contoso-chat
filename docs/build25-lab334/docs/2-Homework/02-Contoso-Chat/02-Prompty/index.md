# Prompty-Based Evaluation

## What is Prompty?

Prompty is an asset format with a support tool and runtime, that helps developers speed up their inner loop for development by effectively _bringing the playground experience into your editor_.

With Prompty, you can
1. Create a prompt asset using a YAML-like specification
1. Construct the prompt template using Markdown syntax
1. Add model configuration and input as frontmatter
1. Run the prompt _in VS Code_ to see model responses
1. Refine template and configuration iteratively _in editor_


### Lab 1: Prompty In Action

1. Visit `src/api/contoso_chat/evaluators/custom_evals/`
1. Open `coherence.prompty` in VS Code.
1. Click the "Play" button in the editor
1. **Observe what happens**

!!! quote "You should see the VS Code Terminal switch to the Output tab and show a rating (1-5) for coherence"

---

## What Are Custom Evaluators?

By default, Azure AI Evaluation has a number of built-in evaluators for quality and safety. But what if you wanted to _customize_ the scoring for a given evaluator, or perhaps _create_ a new evaluator for a metric ("Complexity") that you want to decide the scoring criteria for. Since AI-assisted evaluations are about having one model ("judge") rate the responses of an other model ("app"), we can write custom evaluators with Prompty as well.

---

### Lab 2: View Evaluators

While the Azure AI Evaluation SDK provides built-in evaluators for core quality metrics, the Contoso Chat app also has _custom_ versions of these created to support its own requirements in additon.

Here are the 4 metrics we want to evaluate.

| Metric | What does the metric evaluate? |
|:--|:--|
| **Coherence** | How well do all sentences in the ANSWER fit together? <br/> Do they sound natural when taken as a whole? |
| **Fluency** | What is the quality of individual sentences in the ANSWER? <br/> Are they well-written and grammatically correct? |
| **Groundedness**| Given support knowledge, does the ANSWER use the information provided by the CONTEXT? |
| **Relevance**| How well does the ANSWER address the main aspects of the QUESTION, based on the CONTEXT? |

1. Visit `src/api/contoso_chat/evaluators/custom_evals/`
1. Open `coherence.prompty` in VS Code.
1. Open `fluency.prompty` in VS Code.
1. Open `relevance.prompty` in VS Code.
1. Open `groundedness.prompty` in VS Code.
1. **Take a minute to read the template for each**

    ??? info "CLICK TO EXPAND: Coherence.prompty"

        ``` title="" linenums="0"
        ---
        name: QnA Coherence Evaluation
        description: Evaluates coherence score for QA scenario
        model:
        api: chat
        configuration:
            type: azure_openai
            azure_deployment: gpt-4
            azure_endpoint: ${ENV:AZURE_OPENAI_ENDPOINT}
            api_version: 2024-08-01-preview
        parameters:
            max_tokens: 128
            temperature: 0.2
        inputs:
        question:
            type: string
        context:
            type: object
        answer:
            type: string
        sample:
        question: What feeds all the fixtures in low voltage tracks instead of each light having a line-to-low voltage transformer?
        context: Track lighting, invented by Lightolier, was popular at one period of time because it was much easier to install than recessed lighting, and individual fixtures are decorative and can be easily aimed at a wall. It has regained some popularity recently in low-voltage tracks, which often look nothing like their predecessors because they do not have the safety issues that line-voltage systems have, and are therefore less bulky and more ornamental in themselves. A master transformer feeds all of the fixtures on the track or rod with 12 or 24 volts, instead of each light fixture having its own line-to-low voltage transformer. There are traditional spots and floods, as well as other small hanging fixtures. A modified version of this is cable lighting, where lights are hung from or clipped to bare metal cables under tension
        answer: The main transformer is the object that feeds all the fixtures in low voltage tracks.
        ---
        system:
        You are an AI assistant. You will be given the definition of an evaluation metric for assessing the quality of an answer in a question-answering task. Your job is to compute an accurate evaluation score using the provided evaluation metric. You should return a single integer value between 1 to 5 representing the evaluation metric. You will include no other text or information.

        user:
        Coherence of an answer is measured by how well all the sentences fit together and sound naturally as a whole. Consider the overall quality of the answer when evaluating coherence. Given the question and answer, score the coherence of answer between one to five stars using the following rating scale:
        One star: the answer completely lacks coherence
        Two stars: the answer mostly lacks coherence
        Three stars: the answer is partially coherent
        Four stars: the answer is mostly coherent
        Five stars: the answer has perfect coherency

        This rating value should always be an integer between 1 and 5. So the rating produced should be 1 or 2 or 3 or 4 or 5.

        question: What is your favorite indoor activity and why do you enjoy it?
        answer: I like pizza. The sun is shining.
        stars: 1

        question: Can you describe your favorite movie without giving away any spoilers?
        answer: It is a science fiction movie. There are dinosaurs. The actors eat cake. People must stop the villain.
        stars: 2

        question: What are some benefits of regular exercise?
        answer: Regular exercise improves your mood. A good workout also helps you sleep better. Trees are green.
        stars: 3

        question: How do you cope with stress in your daily life?
        answer: I usually go for a walk to clear my head. Listening to music helps me relax as well. Stress is a part of life, but we can manage it through some activities.
        stars: 4

        question: What can you tell me about climate change and its effects on the environment?
        answer: Climate change has far-reaching effects on the environment. Rising temperatures result in the melting of polar ice caps, contributing to sea-level rise. Additionally, more frequent and severe weather events, such as hurricanes and heatwaves, can cause disruption to ecosystems and human societies alike.
        stars: 5

        question: {{question}}
        answer: {{answer}}
        stars:
        ```
        
---

### Lab 3: Run Evaluators

Click the `play` button in all the four prompty files you opened in the previous step, in some order. 

1. You should see rating show up in the console
1. The rating is for the default "question" in the prompty
1. Now visit the evaluator prompty - and see how it is defined

**Observe the following**

1. The system context describes the purpose of the evaluator
1. The template uses _few-shot prompting_ to give examples
1. The model is then asked to evaluate the response in context

!!! quote "Can you get an intuition for why the model response to the question got those ratings?"

---

### Lab 4: Create Evaluators

Let's revisit the idea of a _Complexity_ evaluation:

1. The customer makes a request that is fairly complex, resulting in a response that is overly full of options - leading to decision fatigue where the customer buys nothing.
1. We want the model to detect these kinds of questions and gently push back to have the customer pick one track at a time.
1. We want to define a complexity rating where 1 means nothing complex happened (good)) and 5 is where model is overloading customer (bad)


    !!! task "Try It: Create a new custom evaluator"

        1. Copy `coherence.prompty` to `complexity.prompty`
        1. Update system message to reflect evaluator goal
        1. Write examples to reflect the complexity rating
        1. Test this with different prompts to see ratings

!!! success "CONGRATULATIONS. You built a custom evaluator with Prompty!"
