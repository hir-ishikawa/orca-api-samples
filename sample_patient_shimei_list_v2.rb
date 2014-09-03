#!/usr/bin/ruby
#-*-coding: utf-8-*-

#------ 患者番号一覧取得

require 'pp'
require 'uri'
require 'net/http'
require 'crack'
require 'crack/xml'


Net::HTTP.version_1_2

HOST = "192.168.4.123"
PORT = "8000"
USER = "ormaster"
PASSWD = "ormaster123"
CONTENT_TYPE = "application/xml"


req = Net::HTTP::Post.new("/api01rv2/patientlst3v2?class=01")
# class :01 新規・更新対象
# class :02 新規対象
#
#

#入力氏名表示
patient_name = ARGV[0]
puts "検索氏名:#{patient_name}"

BODY = <<EOF
<data>
	<patientlst3req type="record">
		<WholeName type="string">#{patient_name}</WholeName>
		<Birth_StartDate type="string"></Birth_StartDate>
		<Birth_EndDate type="string"></Birth_EndDate>
		<Sex type="string"></Sex>
		<InOut type="string"></InOut>
		</patientlst3req>
</data>
EOF

def list_patient(body)
	root = Crack::XML.parse(body)
	#pp root
	result = root["xmlio2"]["patientlst2res"]["Api_Result"]
	unless result == "00"
		puts "error:#{result}"
		exit 1
	end

	pinfo = root["xmlio2"]["patientlst2res"]["Patient_Information"]
	pinfo.each do |patient|
			puts "===================="
			puts "名前:#{patient["WholeName"]}"
			puts "カナ:#{patient["WholeName_inKana"]}"
			puts "生年月日:#{patient["BirthDate"]}"
				if patient["Sex"] == "1"
					patient_Sex ="男"
				else
					patient_Sex ="女"
			end
			puts "性別:#{patient_Sex}"
			#puts "作成日:#{patient["CreateDate"]}"
			#puts "最終更新日:#{patient["UpdateDate"]}"
			puts "===================="
	end

end

req.content_length = BODY.size
req.content_type = CONTENT_TYPE
req.body = BODY
req.basic_auth(USER, PASSWD)

Net::HTTP.start(HOST, PORT) {|http|
	res = http.request(req)
	#puts res.code
	list_patient(res.body)
}

