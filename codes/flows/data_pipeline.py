from prefect import flow, task

@task
def extract():
    return {"data": [1, 2, 3]}

@task
def transform(data):
    return [i * 2 for i in data["data"]]

@task
def load(result):
    print("Loaded:", result)

@flow
def etl_flow():
    data = extract()
    transformed = transform(data)
    load(transformed)

if __name__ == "__main__":
    etl_flow()
