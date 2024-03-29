#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import division, print_function, unicode_literals

from flask import Flask, render_template, request, redirect, \
    url_for
from flask_socketio import SocketIO, join_room, leave_room, send, emit
# pip install pyopenssl
# from OpenSSL import SSL
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson.json_util import dumps
import json

"""
The flask server application to run the website.
Created by @author Chralt
"""

# TODO: IMPORTANT for testing is using Chrome Browser not safari!!!!!!!!!!
'''
The next shows the usage to use tls encryption on website (https).
Please use the lastest encryption method! 
'''
# context = SSL.Context(SSL.TLSv1_2_METHOD)
# context.use_certificate('MyLetsEncrypt.cert')
# context.use_privatekey('myprivatekeyfromletsencrypt.key')

# flask app is initialized
app = Flask(__name__)
socketio = SocketIO(app)

db_client = MongoClient("mongodb://localhost:27017/")

db = db_client["mydatabase"]
db.smart_contracts.delete_many({})
db.smart_contracts.insert_many(
    [{'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Solidity', 'code_lines': 123,
      'state': 'ACTIVE', 'eval_number': 0.74, 'amount': 132, 'smart_contract_description': ''},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Serpent', 'code_lines': 456,
      'state': 'LOCKED', 'eval_number': 1.0, 'amount': 0, 'smart_contract_description': ''},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Vb8C189413', 'language': 'LLL', 'code_lines': 724,
      'state': 'VERIFIED', 'eval_number': 1.0, 'amount': 0, 'smart_contract_description': ''},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Fb8C189413', 'language': 'Mutan', 'code_lines': 70,
      'state': 'VERIFIED', 'eval_number': 1.0, 'amount': 0, 'smart_contract_description': ''},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Cb8C189413', 'language': 'Solidity', 'code_lines': 7523,
      'state': 'LOCKED', 'eval_number': 1.0, 'amount': 0, 'smart_contract_description': ''},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Serpent', 'code_lines': 689,
      'state': 'ACTIVE', 'eval_number': 0.33, 'amount': 56, 'smart_contract_description': ''},
     {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'LLL', 'code_lines': 189,
      'state': 'VERIFIED', 'eval_number': 1.0,
      'amount': 0, 'smart_contract_description': ''}])
db.smart_contracts.insert_one(
    {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Solidity', 'code_lines': 123,
     'state': 'ACTIVE', 'eval_number': 0.65, 'amount': 62, 'smart_contract_description': ''})

# smart contract codes
# TODO
db.sc_codes.delete_many({})


@app.route('/', defaults={'path': ''})
@app.route("/<path:path>")
def index(path):
    # if somebody calls domain only then the user will be redirected to home route
    return redirect(url_for('home'))


@app.route('/upload', methods=['POST', 'GET'])
def upload():
    if request.method == 'POST':
        _id = request.form['_id']
        ether_per_hour = request.form['etherPerHour']
        db.smart_contracts.update_one(
            {'_id': ObjectId(_id)},
            {
                '$set': {
                    'smart_contract_description': str(request.form['smartContractDescription']),
                    'amount': ether_per_hour,
                }
            }, upsert=False
        )
        return redirect(url_for('view', room=_id))
    elif request.method == 'GET':
        _id = db.smart_contracts.insert_one(
            {'address': '0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413', 'language': 'Solidity', 'code_lines': 123,
             'state': 'ACTIVE', 'eval_number': 0.65, 'amount': 69, 'smart_contract_description': ''}).inserted_id
        return render_template('upload.html', _id=_id)


@app.route('/about', methods=['GET'])
def about():
    return render_template('about.html')


@socketio.on('join')
def on_join(data):
    username = data['username']
    room = data['room']
    join_room(room)
    send(username + ' has entered the room.', room=room)
    sc_codes = dumps(db.sc_codes.find({'room': room}))
    if sc_codes == '[]':
        db.sc_codes.insert_one(
            {'text': ["pragma solidity ^0.4.0;", "", "contract SimpleStorage {", "    uint storedData;", "",
                      "    function set(uint x) public {", "        storedData = x;", "    }", "",
                      "    function get() public view returns (uint) {", "        return storedData;", "    }",
                      "}"], 'from': {"line": 0, "ch": 0, "sticky": "null"},
             'to': {"line": 0, "ch": 0, "sticky": "null"}, 'origin': "paste",
             'room': room})
        sc_codes = dumps(db.sc_codes.find({'room': room}))
    emit('getCode', sc_codes, broadcast=False)


@socketio.on('leave')
def on_leave(data):
    username = data['username']
    room = data['room']
    leave_room(room)
    send(username + ' has left the room.', room=room)


@socketio.on('connect')
def on_connect():
    pass


@socketio.on('clientText')
def on_client_text(data):
    # save_editor_text_on_server(data['text'], data['from'], data['to'], data['origin'], data['room'])
    db.sc_codes.insert_one(
        {'text': data['text'], 'from': data['from'], 'to': data['to'], 'origin': data['origin'], 'room': data['room']})
    # only broadcast it to any other then sender
    emit('serverText', data, broadcast=True, room=data['room'], include_self=False)


"""
def save_editor_text_on_server(text, from1, to1, origin, room):
    from_line = from1['line']
    from_char = from1['ch']
    to_line = to1['line']
    to_char = to1['ch']

    if len(text) == 2 and text[0] == '' and text[1] == '':
        handle_line_break(from_line, from_char, room)
    else:
        if from_line == to_line:
            char_list = list(sc_codes[room][from_line])
            if not char_list:
                char_list.append('')
            del char_list[from_char:to_char]
            if origin == 'paste' or origin == '+input':
                for i in range(len(text)):
                    if i == 0:
                        char_list.insert(from_char, text[i])
                    else:
                        sc_codes[room].insert(from_line + i, text[i])
            sc_codes[room][from_line] = ''.join(char_list)
        else:
            for line in range(from_line, to_line + 1):
                char_list = list(sc_codes[room][line])
                if line == from_line:
                    del char_list[from_char:]
                    if origin == 'paste' or origin == '+input':
                        char_list.insert(from_char, text[0])
                elif line == to_line:
                    del char_list[:to_char]
                else:
                    char_list = ['']
                sc_codes[room][line] = ''.join(char_list)


def handle_line_break(from_line, from_char, room):
    # break line
    char_list = list(sc_codes[room][from_line])
    sc_codes[room][from_line] = ''.join(char_list[from_char:])
    sc_codes[room].insert(from_line, ''.join(char_list[:from_char]))
"""


@app.route('/view/<string:room>', methods=['GET'])
def view(room):
    if ObjectId.is_valid(room):
        smart_contract = dumps(db.smart_contracts.find_one({'_id': ObjectId(room)}))
        if smart_contract != 'null':
            return render_template('view.html', room=room,
                                   smart_contract_description=eval(smart_contract)['smart_contract_description'])
    return render_template('page_not_found.html')


@app.route('/home', methods=['GET', 'POST'])
def home():
    # get the arguments of the url: request.args.get('name')
    if request.method == 'GET':
        smart_contracts = db.smart_contracts.find({})
        return render_template('index.html', smart_contracts=smart_contracts)
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
    socketio.run(app, port=5000, debug=True)
