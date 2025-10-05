import os
from fastapi import FastAPI
from pydantic import BaseModel
from parrot import Parrot
from nltk.tokenize import sent_tokenize
import nltk, re

nltk.download("punkt", quiet=True)

# Load model from baked directory
model_path = os.getenv("PARROT_MODEL_PATH", "prithivida/parrot_paraphraser_on_T5")
parrot = Parrot(model_tag=model_path, use_gpu=False)

app = FastAPI()

class TextRequest(BaseModel):
    text: str

def generate_paraphrases(sentence):
    return parrot.augment(
        input_phrase=sentence,
        do_diverse=True,
        adequacy_threshold=0.85,
        fluency_threshold=0.90
    )

def clean_and_join(sentences):
    cleaned = []
    for s in sentences:
        s = s.lower().strip()
        if s and s[-1] in ['.', '!', '?']:
            s = s[:-1]
        if s:
            s = s[0].upper() + s[1:]
        cleaned.append(s)
    return ". ".join(cleaned)

def post_process(text):
    return re.sub(r'\s{2,}', ' ', text).strip()

@app.post("/paraphrase")
def paraphrase(req: TextRequest):
    input_sentences = sent_tokenize(req.text.strip())
    rephrased = []
    for s in input_sentences:
        para = generate_paraphrases(s)
        rephrased.append(para[0][0] if para else s)
    return {"original": req.text, "paraphrased": post_process(clean_and_join(rephrased))}
