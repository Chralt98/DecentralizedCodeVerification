#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import division, print_function, unicode_literals

from flask import Flask, render_template, request, redirect, \
    url_for
from werkzeug.utils import secure_filename
# pip install pyopenssl
# from OpenSSL import SSL
from pymongo import MongoClient

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
db_client = MongoClient("mongodb://localhost:27017/")

db = db_client["mydatabase"]
db.smart_contracts.remove({})
db.smart_contracts.insert_many(
    [{'language': 'solidity', 'code_lines': 123, 'state': 'ACTIVE', 'eval_number': 321, 'amount': 42},
     {'language': 'python', 'code_lines': 456, 'state': 'LOCKED', 'eval_number': 500, 'amount': 0},
     {'language': 'java', 'code_lines': 789, 'state': 'VERIFIED', 'eval_number': 500, 'amount': 0},
     {'language': 'rust', 'code_lines': 789, 'state': 'VERIFIED', 'eval_number': 500, 'amount': 0},
     {'language': 'go', 'code_lines': 789, 'state': 'VERIFIED', 'eval_number': 500, 'amount': 0},
     {'language': 'dart', 'code_lines': 789, 'state': 'VERIFIED', 'eval_number': 500, 'amount': 0},
     {'language': 'solidity', 'code_lines': 789, 'state': 'VERIFIED', 'eval_number': 500,
      'amount': 0}])
db.smart_contracts.insert_one(
    {'language': 'solidity', 'code_lines': 123, 'state': 'ACTIVE', 'eval_number': 321, 'amount': 42})


@app.route('/', defaults={'path': ''})
@app.route("/<path:path>")
def index(path):
    # if somebody calls domain only then the user will be redirected to home route
    return redirect(url_for('home'))


@app.route('/upload', methods=['POST', 'GET'])
def upload():
    if request.method == 'POST':
        # TODO: post the code to the IOTA Tangle and save the IOTA address to the mongoDB database
        print(request.form['codeText'])
        # TODO: check the IOTA Address to be a valid address
        print(request.form['iotaAddress'])
        # TODO: paste code text to the IOTA tangle and save the IOTA address to the mongoDB
    return render_template('upload.html')


@app.route('/about', methods=['GET'])
def about():
    return render_template('about.html')


@app.route('/view', methods=['GET'])
def view():
    return render_template('view.html')


@app.route('/home', methods=['GET'])
def home():
    # get the arguments of the url: request.args.get('name')
    if request.method == 'GET':
        smart_contracts = db.smart_contracts.find({})
        return render_template('index.html', smart_contracts=smart_contracts)


if __name__ == '__main__':
    # usage for the tls encryption for https
    # ssl_context=context
    # set debug to false if production
    # uses threaded if multiple clients request the website this python file will run multi threaded
    app.run(port=5000, debug=True, threaded=True)
