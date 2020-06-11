from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, ForeignKey, Time

Base = declarative_base()


class Lines(Base):
    __tablename__ = 'linia'
    ID_Linia = Column(Integer, primary_key=True, nullable=False)

    def __repr__(self):
        return f"Line no.{self.ID_Linia}"


class Stop(Base):
    __tablename__ = 'Przystanek'
    ID_Przystanek = Column(Integer, primary_key=True,
                           autoincrement=True, nullable=False)
    Nazwa = Column(String(42), nullable=False)

    def __repr__(self):
        return f"Bus stop of ID {self.ID_Przystanek} and name {self.Nazwa}"


class Driver(Base):
    __tablename__ = 'Kierowca'
    ID_Kierowca = Column(Integer, nullable=False,
                         autoincrement=True, primary_key=True)
    Nazwa = Column(String(44))

    def __repr__(self):
        return f"Driver of ID {self.ID_Kierowca} and name {self.Nazwa}"


class Route(Base):
    __tablename__ = 'Trasa'
    ID_Trasa = Column(Integer, nullable=False, primary_key=True)
    ID_Linia = Column(Integer, ForeignKey(
        "Linia.ID_linia"), nullable=False)
    ID_Początek = Column(Integer, nullable=False)
    ID_Koniec = Column(Integer, nullable=False)

    def __repr__(self):
        return f"Route of ID {self.ID_Trasa} on Line {self.ID_Linia} from ID {self.ID_Początek} to ID {self.ID_Koniec}"


class Connection(Base):
    __tablename__ = "Przejazd"
    ID_Przejazd = Column(Integer, nullable=False,
                         primary_key=True, auto_increment=True)
    PrzystanekA = Column(Integer, nullable=False)
    PrzystanekB = Column(Integer, nullable=False)
    ID_Trasa = Column(Integer, ForeignKey('Trasa.ID_Trasa'), nullable=False)

    def __repr__(self):
        return f"Connection of ID {self.ID_Przejazd} on Route {self.ID_Trasa} from Bus Stop of ID {self.PrzystanekA} to Bus Stop of ID {self.PrzystanekB}"


class Schedule(Base):
    __tablename__ = "Terminarz"
    ID_Terminarz = Column(Integer, nullable=False,
                          auto_increment=True, primary_key=True)
    ID_Przejazd = Column(Integer, ForeignKey(
        'Przejazd.ID_Przejazd'), nullable=False)
    Przyjazd = Column(Time)
    Odjazd = Column(Time)

    def __repr__(self):
        return f"Schedule of ID {self.ID_Terminarz} on Connection ID {self.ID_Przejazd} arrival at {self.Przyjazd} departure at {self.Odjazd}"
