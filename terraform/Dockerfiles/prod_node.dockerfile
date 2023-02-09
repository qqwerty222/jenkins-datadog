FROM python:3.10-bullseye

WORKDIR /usr/src/website

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "python","-m", "pytest" ]