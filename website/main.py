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
    [{'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Solidity', 'code_lines': 123,
      'state': 'ACTIVE', 'eval_number': 0.74, 'amount': 132},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Serpent', 'code_lines': 456,
      'state': 'LOCKED', 'eval_number': 1.0, 'amount': 0},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Vb8C189413', 'language': 'LLL', 'code_lines': 724,
      'state': 'VERIFIED', 'eval_number': 1.0, 'amount': 0},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Fb8C189413', 'language': 'Mutan', 'code_lines': 70,
      'state': 'VERIFIED', 'eval_number': 1.0, 'amount': 0},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Cb8C189413', 'language': 'Solidity', 'code_lines': 7523,
      'state': 'LOCKED', 'eval_number': 1.0, 'amount': 0},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Serpent', 'code_lines': 689,
      'state': 'ACTIVE', 'eval_number': 0.33, 'amount': 56},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'LLL', 'code_lines': 189,
      'state': 'VERIFIED', 'eval_number': 1.0,
      'amount': 0}])
db.smart_contracts.insert_one(
    {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Solidity', 'code_lines': 123,
     'state': 'ACTIVE', 'eval_number': 0.65, 'amount': 62})


@app.route('/', defaults={'path': ''})
@app.route("/<path:path>")
def index(path):
    # if somebody calls domain only then the user will be redirected to home route
    return redirect(url_for('home'))


@app.route('/upload', methods=['POST', 'GET'])
def upload():
    if request.method == 'POST':
        # TODO: check the address to be a valid address
        print(request.form['smartContractAddress'])
        return redirect(url_for('view', address=request.form['smartContractAddress']))
    return render_template('upload.html')


@app.route('/about', methods=['GET'])
def about():
    return render_template('about.html')


@app.route('/view/<string:address>', methods=['GET'])
def view(address):
    # TODO: view ethereum address smart contract text code
    code_text = address
    return render_template('view.html', code_text=code_text)


@app.route('/home', methods=['GET', 'POST'])
def home():
    # get the arguments of the url: request.args.get('name')
    if request.method == 'GET':
        return render_template('index.html', smart_contracts=db.smart_contracts.find({}))
    elif request.method == 'POST':
        if request.form['searchAddress'] == '':
            return render_template('index.html', smart_contracts=db.smart_contracts.find({}))
        smart_contracts = db.smart_contracts.find({'address': request.form['searchAddress']})
        return render_template('index.html', smart_contracts=smart_contracts)


if __name__ == '__main__':
    # usage for the tls encryption for https
    # ssl_context=context
    # set debug to false if production
    # uses threaded if multiple clients request the website this python file will run multi threaded
    app.run(port=5000, debug=True, threaded=True)
