#-------------------------------------------------
#
# Project created by QtCreator 2017-05-11T10:36:16
#
#-------------------------------------------------

QT       += core gui webkitwidgets opengl network

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = JSEditTester
TEMPLATE = app
CONFIG += c++11

LIBS += -lxdelta3


SOURCES += main.cpp\
        mainwindow.cpp

HEADERS  += mainwindow.h

FORMS    += mainwindow.ui
