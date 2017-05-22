# -*- coding: utf-8 -*-
import dateutil.parser
import datetime
import urllib
from iso8601 import parse_date
from datetime import datetime, timedelta


def convert_datetime_to_calendar_format(isodate):
    iso_dt = parse_date(isodate)
    day_string = iso_dt.strftime("%d %b %Y %H:%M")
    return day_string


def convert_datetime_to_calendar_plus_days(isodate, dplus):
    iso_dt = parse_date(isodate)
    iso_dt = iso_dt + datetime.timedelta(days=int(dplus))
    day_string = iso_dt.strftime("%d %b %Y %H:%M")
    return day_string


def convert_datetime_to_calendar_plus_minutes(isodate, dplus):
    iso_dt = parse_date(isodate)
    iso_dt = iso_dt + datetime.timedelta(minutes=int(dplus))
    day_string = iso_dt.strftime("%d %b %Y %H:%M")
    return day_string


def get_local_id_from_url(tender_url):
    return str(tender_url[tender_url.rfind("/") + 1:])


def get_local_id_from_url_int(tender_url):
    return int(tender_url[tender_url.rfind("/") + 1:])


def assemble_viewtender_url(home_url, tender_id):
    newUrl = home_url[:home_url.rfind("/dashboard/tender-drafts")]
    return newUrl + "/tenders/" + tender_id

def claim_status(status):
    if status.lower() == u'вимога':
        status = True
    else:
        status = False
    return status

def parse_smth(text, count, delim):
    address = text.split(delim)
    return address[count]

def convert_datetime_to_new(isodate):
    iso_dt = parse_date(isodate)
    day_string = iso_dt.strftime("%d/%m/%Y")
    return day_string

def plus_1_min(date):
    new_time = parse_date(date)
    min1 = timedelta(minutes = 1)
    return datetime.strftime((new_time+min1), "%H:%M")

def plus_20_min(date):
    new_time = parse_date(date)
    min1 = timedelta(minutes =20)
    return datetime.strftime((new_time+min1), "%H:%M")

def convert_datetime_to_new_time(isodate):
    iso_dt = parse_date(isodate)
    day_string = iso_dt.strftime("%H:%M")
    return day_string

def adapt_data(tender_data):
    tender_data.data.procuringEntity['name'] = u"accOwner"
    tender_data.data.procuringEntity['identifier']['legalName'] = u"accOwner"
    tender_data.data.procuringEntity['identifier']['id'] = u"1111111111"
    tender_data.data.procuringEntity['address']['locality'] = u"м. Київ"
    tender_data.data.procuringEntity['address']['postalCode'] = u"00001"
    tender_data.data.procuringEntity['address']['region'] = u"місто Київ"
    tender_data.data.procuringEntity['address']['streetAddress'] = u"accOwner"
    tender_data.data.procuringEntity['address']['streetAddress'] = u"accOwner"
    tender_data.data.lots[0].value['amount'] = repr(tender_data.data.lots[0].value['amount'])
    return tender_data

def tax_adapt(tax):
    if tax == u'(з ПДВ)':
        tax = True
    elif tax == u'з ПДВ':
        tax = True
    elif tax == u' (з ПДВ)':
        tax = True
    else:
        tax = False
    return tax

def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))

def trim_data(data):
    return data.strip()

def participant_status(status):
    if status == u'Переможець':
        status = u'active'
    else:
        status = u'False'
    return status

def parse_address_for_viewer(text, count):
    address = text.split(", ")
    return address[count]

def adapt_supplier_data(supplier_data):
    supplier_phone = supplier_data.data.suppliers[0].contactPoint['telephone']
    phone_len = len(supplier_phone)
    if phone_len > 15:
        supplier_data.suppliers[0].contactPoint['telephone'] = supplier_phone[:15]
    region = supplier_data.data.suppliers[0].address['region']
    if region != u'місто Київ':
        reg = region.split(" ")
        supplier_data.data.suppliers[0].address['region'] = reg[0]
    return supplier_data

def get_numberic_part(somevalue):
    resvalue = ""
    for i in somevalue:
        if i in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]:
            resvalue = resvalue + i
        elif i in [","]:
            resvalue = resvalue + '.'
    return resvalue

def do_strip_date(somevalue):
    resvalue = somevalue.strip()
    resvalue = resvalue.strip("\t\n")
    resvalue = resvalue.replace("\n", " ")
    resvalue = ' '.join(resvalue.split())
    resvalue = resvalue.replace("\t", "")
    resvalue = resvalue.replace("\r", "")
    return resvalue

def convert_dt(somedate):
    dt = datetime.datetime.strptime(somedate, "%d.%m.%Y %H:%M")
    return dt

def adapt_numbers(data):
    return repr(data)

def adapt_numbers2(data):
    return float(data)

def adapt_doc_type(data):
    if data == u'financial_documents':
        data = u'commercialProposal'
    elif data == u'qualification_documents':
        data = u'qualificationDocuments'
    elif data == u'eligibility_documents':
        data = u'eligibilityDocuments'
    else:
        data = u'technicalSpecifications'
    return data

def cut_string(text):
    return text[:-1]

def get_proposition_status(data):
    if data == u'Допущено до аукціону':
        data = u'active'
    elif data == u'На розгляді':
        data = u'pending'
    else:
        data = u'FUCKUP'
    return data

def percents(data):
    return int(data*100)

def get_currency(somevalue):
    resvalue = ""
    for i in somevalue:
        if i not in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "." , ","]:
            resvalue = resvalue + i
    resvalue = resvalue.strip()
    if  resvalue == u'грн':
        resvalue = u'UAH'
    return resvalue









