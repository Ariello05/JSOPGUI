# manager = transporter in case of this file
# ^ Reason why manager is bad name for classes etc.

from sqlalchemy.orm import sessionmaker
from tools import get_correct_answer, create_info_args
import model


LINES = "Lines"
STOPS = "Stops"
DRIVERS = "Drivers"
ROUTES = "Routes"
CONNECTIONS = "Connectins"
SCHEDULE = "Schedule"
table_names = [LINES, STOPS, DRIVERS, ROUTES, CONNECTIONS, SCHEDULE]
table_args = create_info_args(table_names)

ACTION_SEE = "See records"
ACTION_ADD = "Add records"
action_names = [ACTION_SEE, ACTION_ADD]
action_args = create_info_args(action_names)


def query_through(session, model_class):
    result = session.query(model_class).all()
    for row in result:
        print(row)


def run(engine):
    Session = sessionmaker(bind=engine)
    session = Session()
    answer = get_correct_answer("Choose option", action_args).name
    if answer == ACTION_SEE:
        answer = get_correct_answer(
            "See all records from table", table_args).name
        if answer == LINES:
            query_through(session, model.Lines)
        elif answer == STOPS:
            query_through(session, model.Stop)
        elif answer == DRIVERS:
            query_through(session, model.Driver)
        elif answer == ROUTES:
            query_through(session, model.Route)
        elif answer == CONNECTIONS:
            query_through(session, model.Connection)
        elif answer == SCHEDULE:
            query_through(session, model.Schedule)

    elif answer == ACTION_ADD:
        print("TODO")
        pass
