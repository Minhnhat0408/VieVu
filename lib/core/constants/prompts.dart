const summarizeInstruction = '''
Bạn sẽ tóm tắt đoạn hội thoại về chuyến đi và tạo lịch trình dưới dạng List các object,ngoài ra không cần nói gì thêm.
Chỉ cho vào lịch trình các hành động sự kiện có địa điểm (không có thời gian thì ước tính thời gian theo tuyến tính cho phù hợp).
với mỗi object trong ouput có note là nội dung hành động (dựa trên hành động và địa điểm để tạo ra note thú vị),
time là thời gian diễn ra hành động, place là địa điểm diễn ra hành động,
metaData là thông tin chi tiết của địa điểm đó (lấy toàn bộ từ dữ liệu trong metadata có title bằng place).
Có nhiều metadata có thể tên cùng 1 địa điểm nhưng hãy lấy cái  đầy đủ thông tin nhất.
MetaData của output không đưuọc để trống ít nhất phải có title và type.
Trong đoạn tin nhắn có thể cuối tin nhắn có đoạn |No| hoặc |Yes| để biết người dùng có đồng ý hay không,
nếu |No| thì bỏ nó ra khỏi lịch trình không tóm tắt nó,
còn đuôi |Yes| thì chắc chắn thêm vào lịch trình tóm tắt, không có đuôi này thì tóm tắt bình thường.
Nếu input có thêm Previous Summary (cũng là 1 List object) thì cứ tóm tắt đoạn hội thoại mới và ghép nó
vào sao cho phù họp với cái previous sao cho thành 1 cái mới đầy đủ.
Áp dụng các thời gian mặc định sau:
"sáng": 8h00
"chiều": 15h00
"tối": 19h00

Ví dụ Input:

Conversation:
["Chốt đi sáng thứ 6 đến tối chủ nhật nhé."
,"Sáng 8h hôm đầu đi ăn bún bò ở quán Bún Thanh Hoa nhé."
,"Chiều đi tham quan Hạ Long.|Yes|"
,"Tối về ăn hải sản."
,"Ơ vậy tập trung ở đâu."
,"Sáng thứ 6 tập trung ở Sơn Tây, Hà Nội."
,"Tối chủ nhật thì không được rồi,chiều về được không"
,"Được, chiều chủ nhật về."]
Travel dates: from 25/10/2024 to 27/10/2024
Metadata: [
{"title": "Sơn Tây, Hà Nội",
"latittude": 21.1371,
"longitude": 105.5044},
{"title": "Hạ Long",
"latittude": 20.9101,
"longitude": 107.1839},
{"title": "hạ Long",},
{"title": "quán Bún Thanh Hoa",
"latittude": 21.0285
"longitude": 105.8523},
].

Ví dụ Output:
[
{"day":"2024-10-25","events":[{"time":"2024-10-25T08:00:00","note":"Khởi hành đến Hạ Long","place":"Sơn Tây, Hà Nội", metaData: {"title": "Sơn Tây, Hà Nội",
"latittude": 21.1371,"longitude": 105.5044}  },{"time":"2024-10-25T19:00:00","note":"Nghỉ ngơi, ăn tối","place":""}]},
{"day":"2024-10-26","events":[{"time":"2024-10-26T08:00:00","note":"Ăn bún bò","place":"quán Bún Thanh Hoa", metaData: {"title": "quán Bún Thanh Hoa",
"latittude": 21.0285,longitude": 105.8523}},{"time":"2024-10-26T15:00:00","note":"Tham quan","place":"Hạ Long",  metaData: {"title": "Hạ Long",
"latittude": 20.9101,"longitude": 107.1839},}]},
{"day":"2024-10-27","events":[]}
]
''';

const readingInstruction = '''Bạn sẽ nhận vào một List Object lịch trình và biến nó thành văn bản tóm tắt cho người đọc dễ đọc, không cần nói gì thêm.''';
