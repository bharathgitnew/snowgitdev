# # Encrypt / Decrypt string using AES-SIV cipher.

import os
import sys

from miscreant.aes.siv import SIV

from include.Python.utils.logging.logging import Logging, LogKind


class encrypt_decrypt(object):

    def __init__(self, key=None, nonce=None, gen_key=False, gen_nonce=False):
        """
        Provide the `key` and `nonce` to use if you have one in hex format. To pre-generate automatically on initialization
        set `_gen_key` to true and/or `_gen_nonce` to true

        Paramters
        ---------
        key : str
            the key (as a hex) to use for encrypt / decrypt
        nonce
            the nonce (as a hex) to use for encrypt / decrypt
        """

        try:
            self._key_hex = key
            self._nonce_hex = nonce

            if key == None:
                self._key = key
            else:
                self._key = bytes.fromhex(key)

            if nonce == None:
                self._nonce = nonce
            else:
                self._nonce = bytes.fromhex(nonce)

            if gen_key:
                self.generate_key()

            if gen_nonce:
                self.generate_nonce()
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "encrypt_decrypt", "init", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def generate_key(self):
        try:
            self._key = SIV.generate_key()
            self._key_hex = bytes(self._key).hex()
            return self._key_hex
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "encrypt_decrypt", "generate_key", "Exception %s ::  %s" % (e, msg))

    def generate_nonce(self):
        try:
            self._nonce = os.urandom(16)
            self._nonce_hex = bytes(self._nonce).hex()
            return self._nonce_hex
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "encrypt_decrypt", "generate_nonce", "Exception %s ::  %s" % (e, msg))

    def encrypt(self, _data):
        """Encrypts string using key and nonce when class was initialized

        Returns
        ----------
        str
            The encrypted string

        """
        try:
            siv = SIV(self._key)
            ciphertext = None
            if type(_data) == bytes:
                # if _data is already bytes, don't try to convert to bytes first
                ciphertext = siv.seal(_data, [self._nonce])
            else:
                # otherwise, convert _data to bytes
                ciphertext = siv.seal(_data.encode(), [self._nonce])

            #print("\"%s\" data was encrypted.\nFor decryption, use the following salt: %s:%s" % (
            #    _data, self._key_hex, self._nonce_hex))

            return ciphertext.hex()
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "file_utils", "encrypt", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def decrypt(self, _data):
        """Decrypts string using key and nonce when class was initialized

        Returns
        ----------
        str
            The decrypted string

        """
        try:
            siv = SIV(self._key)
            encrypted = bytes.fromhex(_data)
            ciphertext = siv.open(encrypted, [self._nonce])
            decrypted = ciphertext.decode('utf-8')

            #print("\"%s\" data was encrypted.\nFor decryption, use the following salt: %s:%s" % (
            #    _data, self._key_hex, self._nonce_hex))

            return decrypted
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "file_utils", "decrypt", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)