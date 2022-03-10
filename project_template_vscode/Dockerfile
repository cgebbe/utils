# hugginface docker
FROM huggingface/transformers-pytorch-gpu:4.9.1 
RUN pip install datasets
RUN pip install seqeval
RUN pip install tensorboard

# kaggle docker
# FROM gcr.io/kaggle-gpu-images/python:v111

# tools
# TODO: install git-lfs
RUN git lfs install

# linting
RUN pip install black

# https://github.com/microsoft/vscode-remote-release/issues/22#issuecomment-488843424
ARG USERNAME=cgebbe
RUN useradd -m $USERNAME
ENV HOME /home/$USERNAME
USER $USERNAME
