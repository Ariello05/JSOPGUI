# pymysql
# PyMySQL[rsa]
# cryptography
# sqlalchemy


from sqlalchemy import create_engine
import secrets
import session_passenger
import session_manager
from tools import get_correct_answer, create_info_args


def make_passenger_engine():
    return create_engine("mysql+pymysql://{0}:{1}@{2}/{3}".format(
        secrets.dbpassenger, secrets.dbpassword_passenger, secrets.dbhost, secrets.dbname), echo=False)


def make_manager_engine():
    return create_engine("mysql+pymysql://{0}:{1}@{2}/{3}".format(
        secrets.dbmanager, secrets.dbpassword_manager, secrets.dbhost, secrets.dbname), echo=False)


PASSENGER = "passenger"
MANAGER = "manager"
login_names = [PASSENGER, MANAGER]
login_args = create_info_args(login_names)

if __name__ == "__main__":

    answer = get_correct_answer("Login as:", login_args).name

    if answer == PASSENGER:
        engine = make_passenger_engine()
        session_passenger.run(engine)
    else:
        engine = make_manager_engine()
        session_manager.run(engine)
