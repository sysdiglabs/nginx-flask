FROM alpine
RUN apk add py-pip
RUN pip install flask
COPY app.py /app.py
EXPOSE 5000
ENTRYPOINT ["python", "./app.py"]
