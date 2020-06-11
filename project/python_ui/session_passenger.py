from sqlalchemy.orm import sessionmaker

from model import Lines


class RouteResult:
    def __init__(self, number, start_name, end_name):
        self.number = number
        self.start_name = start_name
        self.end_name = end_name

    def __repr__(self):
        return f"Route No.{self.number} from {self.start_name} to {self.end_name}"


def run(engine):
    Session = sessionmaker(bind=engine)
    session = Session()

    print("Showing all avaible routes")
    connection = engine.raw_connection()
    cursor = connection.cursor()
    cursor.callproc("Select_TrasaStandardFormat")
    for item in cursor.fetchall():
        print(RouteResult(item[0], item[1], item[2]))

    cursor.close()
    connection.commit()
    print("Selecting routes, checking terminal etc. later ... or never TODO")
