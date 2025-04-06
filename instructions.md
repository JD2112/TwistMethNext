🛠️ Setup Steps
Ensure these are in place in your repo:
A root-level mkdocs.yml
Docs folder: docs/
Your GitHub Action to deploy docs (you already have this!)
Enabled GitHub Pages:
Source: gh-pages branch
Folder: / (root)
Run the first manual deployment (once): You can do this locally to initialize the gh-pages branch:
pip install mike mkdocs-material
git checkout main

mike delete latest
mike deploy --update-aliases 1.0 latest

mike set-default latest
git push origin gh-pages
⚠️ Note: This creates the gh-pages branch and folder structure you see in nallo.
Now your GitHub Action takes over: Every time you push to main or devel, it will:
Extract the version from nextflow.config
Use mike to deploy that version to gh-pages
Update versions.json
Keep folder structure like:
gh-pages/
├── devel/
├── latest/
├── 1.0/
├── index.html  ← redirect to latest
└── versions.json