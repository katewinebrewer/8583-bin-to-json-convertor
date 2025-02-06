# 8583-bin-to-json-convertor
An app that accepts binary ISO 8583 messages and delivers its json equivalent.
The app is very adaptable just have a look to the EBNF source file (SSA.bnf) and you will see how to change it to your needs.
Compile your adaptation using the linux command ./EBNF.sh. Have your EBNF development environment as implied in the Github EBNFPlus repositry.

## Usage
E.g. type *SSA 001.bin*, where *SSA* is the app and *001.bin* is the file that contains the IFSF message in binary format.

The SSA will convert your binary into something like:

    "{"TrxStream":{
    
    "1100 AuthorizationRequest":{
	"BitMap0" : "03 04 07 11 12 22 24 26 32 35 41 42 43 48 49 52 53 59 64",
	"B03 Processing code"		: {
		"P12" : "00 Debits Payment/Goods and services",
		"P34" : "00 Unspecified account",
		"P45" : "00 Unspecified account"},
	"B04 Amount transaction"	: "000000010000(100.00[l])",
	"B07 Date time transmission"	: "11-03T14:24:23.000",
	"B11 STAN"			: "476445",
	"B12 Date time transaction"	: "2022-11-21T14:40:41.000",
	"B22 POS data code" 		: {
		"P1  Technical ability"       : "2 Magnetic stripe",
		"P2  Authentication ability"  : "1 PIN",
		"P3  Card capture ability"    : "0 None",
		"P4  Operating Environment"   : "2 OPT",
		"P5  Card holder presence"    : "0 Card holder present",
		"P6  Card presence"           : "1 Card present",
		"P7  Card data input mode"    : "2 Magn used",
		"P8  Card holder auth method" : "1 PIN used",
		"P9  Card holder auth entity" : "3 Authorising agent used",
		"P10 CAD can update card"     : "1 CAD cannot update card",
		"P11 POI output ability"      : "2 Print",
		"P12 PIN capture capability"  : "12 digit"},
	"B24 Function code" 		: "101 (Original authorization amount estimated)",
	"B26 Card acceptor busnss code" : "5541 (Service station)",
	"B32 Acquiring institution ID"	: "0000000005",
	"B35 Track 2"			: "7778**********90072=24074001100000000",
	"B41 Terminal ID"		: "DE040951",
	"B42 CAIC"			: "00000DEDE040900",
	"B43 CAN/L"			: "\\An der Weidenmühle\\Gundersheim - IDS\\67598        DEU",
	"B48 Msg ctrl data elements"	: {
		"BitMap48" : "03 04 14 38",
		"B03 Language code"		: "DE",
		"B04 Batch/sequence number"	: "0000000001",
		"B14 PIN encryption method"	: "33",
		"B38 Pump linked indicator"	: "1"},
	"B49 Currency code"		: "999 (Liter IDS)",
	"B52 PIN data"		: "101597DC78DB9BEB",
	"B53 Security related info"	: {
		"B53.1 Key generation master key": "55",
		"B53.2 Key version master key"   : "01",
		"B53.3 RNDmes" : "F7B508158EA3A7626B210333D3274004",
		"B53.4 RNDpac" : "68198EC2D255DF85BA81D7CFADB73B97"},
	"B59 Transport data"		: "0000007357618177",
	"B64 MAC"			: "A487C70DFFFFFFFF"},

     "1110 AuthorizationResponse":{
	"BitMap0" : "03 04 07 11 12 30 32 38 39 41 42 48 49 53 59 62 64",
	"B03 Processing code"		: {
		"P12" : "00 Debits Payment/Goods and services",
		"P34" : "00 Unspecified account",
		"P45" : "00 Unspecified account"},
	"B04 Amount transaction"	: "000000007000(70.00[l])",
	"B07 Date time transmission"	: "11-21T13:40:53.000",
	"B11 STAN"			: "476445",
	"B12 Date time transaction"	: "2022-11-21T14:40:41.000",
	"B30 Original amount"		: "(70.00[l])",
	"B32 Acquiring institution ID"	: "0000000005",
	"B38 Authorisation code"	: "      ",
	"B39 Action code"		: "002 (Approved, for partial amount)",
	"B41 Terminal ID"		: "DE040951",
	"B42 CAIC"			: "00000DEDE040900",
	"B48 Msg ctrl data elements"	: {
		"BitMap48" : "04 09",
		"B04 Batch/sequence number"	: "0000000001",
		"B09 Track2 2nd card"		: "00"},
	"B49 Currency code"		: "999 (Liter IDS)",
	"B53 Security related info"	: {
		"B53.1 Key generation master key": "55",
		"B53.2 Key version master key"   : "01",
		"B53.3 RNDmes" : "F7B508158EA3A7626B210333D3274004",
		"B53.4 RNDpac" : "68198EC2D255DF85BA81D7CFADB73B97"},
	"B59 Transport data"		: "0000000001476445",
	"B62 Product sets"		: {
		"00" : "All products allowed",
		"B62.2" : "0   Default device type",
		"B62.3" : "000 Message"},
	"B64 MAC"			: "A487C70DFFFFFFFF"},

     "1220 TransactionAdvice":{
	"BitMap0" : "03 04 07 11 12 22 24 25 26 32 35 38 39 41 42 43 48 49 53 56 59 63 64",
	"B03 Processing code"		: {
		"P12" : "00 Debits Payment/Goods and services",
		"P34" : "00 Unspecified account",
		"P45" : "00 Unspecified account"},
	"B04 Amount transaction"	: "000000007000(70.00[l])",
	"B07 Date time transmission"	: "11-03T14:26:16.000",
	"B11 STAN"			: "658275",
	"B12 Date time transaction"	: "2022-11-21T14:40:53.000",
	"B22 POS data code" 		: {
		"P1  Technical ability"       : "2 Magnetic stripe",
		"P2  Authentication ability"  : "1 PIN",
		"P3  Card capture ability"    : "0 None",
		"P4  Operating Environment"   : "2 OPT",
		"P5  Card holder presence"    : "0 Card holder present",
		"P6  Card presence"           : "1 Card present",
		"P7  Card data input mode"    : "2 Magn used",
		"P8  Card holder auth method" : "1 PIN used",
		"P9  Card holder auth entity" : "3 Authorising agent used",
		"P10 CAD can update card"     : "1 CAD cannot update card",
		"P11 POI output ability"      : "2 Print",
		"P12 PIN capture capability"  : "12 digit"},
	"B24 Function code" 		: "202 (Previously approved authorization â amount differs (1220 previously authorised with 1100))",
	"B25 Message reason code"	: "1004 (Terminal Processed)",
	"B26 Card acceptor busnss code" : "5541 (Service station)",
	"B32 Acquiring institution ID"	: "0000000005",
	"B35 Track 2"			: "7778**********90072=24074001100000000",
	"B38 Authorisation code"	: "349463",
	"B39 Action code"		: "000 (Approved)",
	"B41 Terminal ID"		: "DE040951",
	"B42 CAIC"			: "00000DEDE040900",
	"B43 CAN/L"			: "\\An der Weidenmühle\\Gundersheim - IDS\\67598        DEU",
	"B48 Msg ctrl data elements"	: {
		"BitMap48" : "03 04 38 39",
		"B03 Language code"		: "DE",
		"B04 Batch/sequence number"	: "0000000001",
		"B38 Pump linked indicator"	: "1",
		"B39 Delivery note number"	: "7357510145"},
	"B49 Currency code"		: "999 (Liter IDS)",
	"B53 Security related info"	: {
		"B53.1 Key generation master key": "55",
		"B53.2 Key version master key"   : "01",
		"B53.3 RNDmes" : "47D9318B9479F075ABA32FBA45E49AED",
		"B53.4 RNDpac" : "00000000000000000000000000000000"},
	"B56 Original data elements"	: "1100476445221121144041",
	"B59 Transport data"		: "0000007357618178",
	"B63 Product data"		: {
		"B63-1 Service level"      : "S=Self serve",
		"B63-2 Number of products" : "01",
		"B63-3 Product code"       : "001 Diesel",
		"B63-4 Unit of measure"    : "Liter",
		"B63-5.1 Quantity"         : "85.00",
		"B63-5.2 Pump"             : "1",
		"B63-5.3 Nozzle"           : "1",
		"B63-6 Unit Price"         : "1.622",
		"B63-7 Amount"             : "137.87",
		"B63-8 Tax code"           : "2",
		"B63-9 Added product code" : "3"},
	"B64 MAC"			: "0F67B5CCFFFFFFFF"},

     "1230 AuthorizationResponse":{
	"BitMap0" : "03 04 07 11 12 32 38 39 41 42 48 49 53 59 64",
	"B03 Processing code"		: {
		"P12" : "00 Debits Payment/Goods and services",
		"P34" : "00 Unspecified account",
		"P45" : "00 Unspecified account"},
	"B04 Amount transaction"	: "000000007000(70.00[l])",
	"B07 Date time transmission"	: "11-21T13:40:54.000",
	"B11 STAN"			: "658275",
	"B12 Date time transaction"	: "2022-11-21T14:40:53.000",
	"B32 Acquiring institution ID"	: "0000000005",
	"B38 Authorisation code"	: "349463",
	"B39 Action code"		: "000 (Approved)",
	"B41 Terminal ID"		: "DE040951",
	"B42 CAIC"			: "00000DEDE040900",
	"B48 Msg ctrl data elements"	: {
		"BitMap48" : "04 09",
		"B04 Batch/sequence number"	: "0000000001",
		"B09 Track2 2nd card"		: "00"},
	"B49 Currency code"		: "999 (Liter IDS)",
	"B53 Security related info"	: {
		"B53.1 Key generation master key": "55",
		"B53.2 Key version master key"   : "01",
		"B53.3 RNDmes" : "47D9318B9479F075ABA32FBA45E49AED",
		"B53.4 RNDpac" : "00000000000000000000000000000000"},
	"B59 Transport data"		: "",
	"B64 MAC"			: "0F67B5CCFFFFFFFF"}
     }}"

