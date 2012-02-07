from astral import Astral, City
from datetime import datetime, date, timedelta

a = Astral()
a.solar_depression = 'civil'

def _check(pred,true):
    if true <= pred:
        assert abs((pred-true).seconds)<60,pred
    else:
        assert abs((true-pred).seconds)<60,pred

def test_from_CityDB():

    city = a["New York"]
    sun = city.sun(date=date(2009, 4, 22), local=False)
    pred = sun['sunrise'].replace(tzinfo=None)
    true = datetime(2009,4,22,10,6)
    _check(pred,true)
    pred = sun['sunset'].replace(tzinfo=None)
    true = datetime(2009,4,22,23,43)
    _check(pred,true)

def test_create_city():
    lat = 43.658931
    lon = -79.380341
    city = City(("Toronto","Canada",lat,-lon,"US/Eastern"))
    date = datetime(2012,1,9)
    sun = city.sun(date=date,local=False)
    pred = sun['sunrise'].replace(tzinfo=None)
    true = datetime(2012,1,9,12,50)
    _check(pred,true)
    pred = sun['sunset'].replace(tzinfo=None)
    true = datetime(2012,1,9,21,59)
    _check(pred,true)