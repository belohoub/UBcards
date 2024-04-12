/*
This code was a part of cardwallet ubuntu-touch application
 
Copyright (c) 2015, Matthew Edwards 
Copyright (c) 2023, Jan Belohoubek, it@sfortelem.cz

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
*/


/* Symbol names reference: https://sourceforge.net/p/zbar/code/ci/default/tree/zbar/symbol.c*/
function stringToBarcode (type, str)
{
    switch (type)
    {
    case undefined:case undefined:
    case 'CODE-128':
        if (/^-?\d+$/.test(str)) {
            /* Numeric-only codes are type C*/
            return "Ò" + getCodeC(str) + "Î";
        } else {
            return "Ì" + getCodeB(str) + "Î";
        }
    
    case 'DataBar':
        return "Ò" + getCodeGS1(str) + "Ó";

    case 'UPC-A':
    case 'EAN-13':
    case 'ISBN-13':
        return ":" + getEAN13(str) + "+";

    case 'EAN-8':
        return ":" + getEAN8(str) + "+";

    case 'I2/5':
        return "(" + getI2of5(str) + ")";
        
    case 'CODE-39':
        return "*" + str.toUpperCase().replace (/[^A-Z\s\d-$%./+]/g, "") + "*";
        
    case 'PICTURE':
        return "";
    }
}

function calculateCheck (code, start)
{
    var CheckSum = start;
    var skips = 0;
	for (var i = 0; i < code.length; i++)
    {
        if (code[i] < 0)
        {
            skips++;
            continue;
        }

        CheckSum += code[i] * (i + 1 - skips);
    }
	return CheckSum % 103;
}

function getCharacterFromValue(v)
{
	if (v >= 0 && v <= 94)
	{
		return String.fromCharCode(v + 32);
	}
	else if (v >= 95 && v <= 102)
	{
		return String.fromCharCode(v + 100)
	}
	return "";
}

function getValueFromCharacter(v)
{
    var value = v.charCodeAt(0);
    if (value >= 32 && value <= 126)
    {
        return value - 32;
    }
    else if (value >= 195 && value <= 202)
    {
        return value - 100;
    }
    return -1;
}

function getCodeB (code)
{
    code = code.replace(/[^\s\da-zA-Z!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~]/g, "");
    var codeArray = [];

    for (var i = 0; i < code.length; i++)
	{
        codeArray.push(getValueFromCharacter(code[i]));
    }

    return escapeString(code + getCharacterFromValue(calculateCheck(codeArray, 104)));
}

function getCodeC (code)
{
    var codeArray = [];
    var codeString = "";

    for (var i = 0; i < code.length; i+=2)
    {
        var value = parseInt (code.substring(i, i+2));
        if (isNaN (value)) return "";
        codeArray.push (value);
        codeString += getCharacterFromValue(value);
    }

    return escapeString(codeString + getCharacterFromValue(calculateCheck (codeArray, 105)));
}

function getCodeGS1 (code)
{
    var codeArray = [102];
    var codeString = "\xCA";

    for (var i = 0; i < code.length; i+=2)
    {
        var value = parseInt (code.substring (i, i+2));
        if (isNaN (value)) return "";
        codeArray.push (value);
        codeString += getCharacterFromValue (value);
    }

    return escapeString (codeString + getCharacterFromValue (calculateCheck (codeArray, 105)));
}

function getEAN13 (code)
{
    var parityMasks = [0, 11, 13, 16, 19, 25, 28, 21, 22, 26];
    var firstDigit = parseInt (code[0]);
    var parityMask = parityMasks [firstDigit];
    var codeString = "";

    var checkSum = firstDigit;
    var weight = 3;

    for (var i = 1; i < 12; i++)
    {
        var digit = parseInt (code[i]);
        checkSum += digit * weight;
        weight = (weight === 3 ? 1 : 3);

        if (i < 7)
        {
            var parity = (32 >> (i-1)) & parityMask;
            if (parity === 0)
            {
                codeString += String.fromCharCode (65 + digit);
            }
            else
            {
                codeString += String.fromCharCode (75 + digit);
            }
        }
        else
        {
            if (i === 7)
            {
                codeString += "*";
            }
            codeString += String.fromCharCode (97 + digit);
        }
    }

    codeString += String.fromCharCode (97 + (10 - checkSum % 10) % 10);

    return escapeString (codeString);
}

function getEAN8 (code)
{
    var codeString = "";

    var checkSum = 0;
    var weight = 3;

    for (var i = 0; i < 7; i++)
    {
        var digit = parseInt (code[i]);
        checkSum += digit * weight;
        weight = (weight === 3 ? 1 : 3);

        if (i < 4)
        {
            codeString += String.fromCharCode (65 + digit);
        }
        else
        {
            if (i === 4)
            {
                codeString += "*";
            }
            codeString += String.fromCharCode (97 + digit);
        }
    }

    codeString += String.fromCharCode (97 + (10 - checkSum % 10) % 10);

    return escapeString (codeString);
}

function getI2of5 (code)
{
    if ((code.length & 1) === 1) return "";
	
	var codeString = "";
	
	for (var i = 1; i < code.length; i += 2)
	{
        var value = parseInt (code[i-1] + code[i]);

		if (value < 50)
			codeString += String.fromCharCode (value + 0x30);
		else
			codeString += String.fromCharCode (value + 0x8e);
	}

    return escapeString (codeString);
}

function escapeString (str)
{
    str = str.replace (/&/g, "&amp;");
    str = str.replace (/</g, "&lt;");
    str = str.replace (/>/g, "&gt;");
	
	return str;
}
