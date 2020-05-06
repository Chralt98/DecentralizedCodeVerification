#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import division, print_function, unicode_literals

from flask import Flask, render_template, request, redirect, \
    url_for, make_response, session, escape, jsonify, Response
from functools import wraps
import json
# pip install pyopenssl
# from OpenSSL import SSL
import os
import werkzeug
import re

"""
The flask server application to run the website.
Created by @author Chralt
"""

'''
The next shows the usage to use tls encryption on website (https).
Please use the lastest encryption method!
'''
# context = SSL.Context(SSL.TLSv1_2_METHOD)
# context.use_certificate('MyLetsEncrypt.cert')
# context.use_privatekey('myprivatekeyfromletsencrypt.key')

# flask app is initialized
app = Flask(__name__)


@app.errorhandler(werkzeug.exceptions.NotFound)
def notfound(e):
    response = jsonify(error=str(e), mykey='myvalue')
    # get post of json_data = json.loads(jsondata)
    # error is key and str(e) is value
    return response, e.code


@app.route('/', defaults={'path': ''})
@app.route("/<path:path>")
def index(path):
    # if somebody calls domain only then the user will be redirected to home route
    return redirect(url_for('home'))


@app.route('/home', methods=['POST', 'GET'])
def home():
    # get the arguments of the url: request.args.get('name')
    if request.method == 'GET':
        return render_template('index.html')


if __name__ == '__main__':
    # usage for the tls encryption for https
    # ssl_context=context
    # set debug to false if production
    # uses threaded if multiple clients request the website this python file will run multi threaded
    app.run(port=1414, debug=True, threaded=True)
