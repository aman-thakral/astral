cdef extern from "math.h":
    double sin(double theta)
    double cos(double theta)
    double tan(double theta)
    double acos(double x)
    double asin(double x)
    double floor(double x)

import math

cdef inline double pi(): return math.pi
cdef inline double radians(double x): return PI*x/180.
cdef inline double degrees(double x): return 180.*x/PI

cdef PI = pi()

cdef double mean_obliquity_of_ecliptic(double juliancentury):
    seconds = 21.448 - juliancentury * (46.815 + juliancentury * (0.00059 - juliancentury * (0.001813)))
    return 23.0 + (26.0 + (seconds / 60.0)) / 60.0
    
cdef double obliquity_correction(double juliancentury):
    e0 = mean_obliquity_of_ecliptic(juliancentury)
    omega = 125.04 - 1934.136 * juliancentury
    return e0 + 0.00256 * cos(radians(omega))

cdef double geom_mean_long_sun(juliancentury):
    l0 = 280.46646 + juliancentury * (36000.76983 + 0.0003032 * juliancentury)
    return l0 % 360.0

cdef double eccentricity_earth_orbit(double juliancentury):
    return 0.016708634 - juliancentury * (0.000042037 + 0.0000001267 * juliancentury)

cdef double geom_mean_anomaly_sun(double juliancentury):
    return 357.52911 + juliancentury * (35999.05029 - 0.0001537 * juliancentury)

cdef double sun_eq_of_center(double juliancentury):
    m = geom_mean_anomaly_sun(juliancentury)
    mrad = radians(m)
    sinm = sin(mrad)
    sin2m = sin(mrad + mrad)
    sin3m = sin(mrad + mrad + mrad)

    c = sinm * (1.914602 - juliancentury * (0.004817 + 0.000014 * juliancentury)) + \
        sin2m * (0.019993 - 0.000101 * juliancentury) + sin3m * 0.000289
       
    return c

cdef double sun_true_long(double juliancentury):
    l0 = geom_mean_long_sun(juliancentury)
    c = sun_eq_of_center(juliancentury)
    return l0 + c
    
cdef double _sun_apparent_long(double juliancentury):
    O = sun_true_long(juliancentury)

    omega = 125.04 - 1934.136 * juliancentury
    return O - 0.00569 - 0.00478 * sin(radians(omega))
    
def _sun_declination(juliancentury):
    e = obliquity_correction(juliancentury)
    lambd = _sun_apparent_long(juliancentury)
    sint = sin(radians(e)) * sin(radians(lambd))
    return degrees(asin(sint))
    
def _hour_angle(latitude, solar_dec, solar_depression):
    latRad = radians(latitude)
    sdRad = radians(solar_dec)
    HA = (acos(cos(radians(90 + solar_depression)) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad)))
    
    return HA

def _eq_of_time(juliancentury):
    epsilon = obliquity_correction(juliancentury)
    l0 = geom_mean_long_sun(juliancentury)
    e = eccentricity_earth_orbit(juliancentury)
    m = geom_mean_anomaly_sun(juliancentury)

    y = tan(radians(epsilon) / 2.0)
    y = y * y

    sin2l0 = sin(2.0 * radians(l0))
    sinm = sin(radians(m))
    cos2l0 = cos(2.0 * radians(l0))
    sin4l0 = sin(4.0 * radians(l0))
    sin2m = sin(2.0 * radians(m))

    Etime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0 - \
            0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m

    return degrees(Etime) * 4.0

def _julianday(day, month, year):
    if month <= 2:
        year = year - 1
        month = month + 12
    
    A = floor(year / 100.0)
    B = 2 - A + floor(A / 4.0)

    jd = floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day - 1524.5
    if jd > 2299160.4999999:
        jd += B
        
    return jd

def _sun_eq_of_center(juliancentury):
    m = geom_mean_anomaly_sun(juliancentury)

    mrad = radians(m)
    sinm = sin(mrad)
    sin2m = sin(mrad + mrad)
    sin3m = sin(mrad + mrad + mrad)

    c = sinm * (1.914602 - juliancentury * (0.004817 + 0.000014 * juliancentury)) + \
        sin2m * (0.019993 - 0.000101 * juliancentury) + sin3m * 0.000289
        
    return c