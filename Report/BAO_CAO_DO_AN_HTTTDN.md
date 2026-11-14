# BÁO CÁO ĐỒ ÁN HỌC PHẦN
## HỆ THỐNG THÔNG TIN DOANH NGHIỆP (MÃ HP: 841065)
**TRƯỜNG ĐẠI HỌC SÀI GÒN (SGU) – KHOA CÔNG NGHỆ THÔNG TIN**
**HỌC KỲ 1 – NĂM HỌC 2026 – 2027**

---

### ĐỀ TÀI:
**XÂY DỰNG HỆ THỐNG THÔNG TIN QUẢN TRỊ DOANH NGHIỆP THƯƠNG MẠI SGU TECH VÀ MÔ PHỎNG PHÂN HỆ QUẢN LÝ QUAN HỆ KHÁCH HÀNG (CRM - MỤC III.4)**

* **Nhóm thực hiện:** Nhóm 05
* **Giảng viên hướng dẫn:** [Tên Giảng Viên Phụ Trách]
* **Thời gian chấm đồ án:** Tuần 10 - 11 (09/11/2026 – 22/11/2026)

---

### BIÊN BẢN PHÂN CÔNG KHỐI LƯỢNG CÔNG VIỆC VÀ TỰ ĐÁNH GIÁ (15 TUẦN)

| STT | MSSV | Họ và Tên | Nhiệm vụ chính được phân công | Tỷ lệ đóng góp (%) | Điểm tự đánh giá | Chữ ký |
| :---: | :---: | :--- | :--- | :---: | :---: | :---: |
| 1 | 3123411261 | [Huỳnh Tuấn Tài] | **Nhóm trưởng:** Khảo sát HTTT, Phân tích nghiệp vụ, Viết bài toán mô tả, Kiểm thử (Test case), Quản lý tiến độ dự án. | 100% | 10 / 10 | |
| 2 | 3123411267 | [Hoàng Thái Thanh] | Vẽ Sơ đồ chức năng (BFD), Sơ đồ ngữ cảnh, Sơ đồ DFD mức đỉnh, Xây dựng bảng từ điển CSDL. | 100% | 10 / 10 | |
| 3 | 3123411157 | [Nguyễn Đăng Khoa] | Thiết kế CSDL SQL Server 9 bảng, Viết kịch bản Backup/Restore, Xây dựng Backend ASP.NET Core API. | 100% | 10 / 10 | |
| 4 | 3123411080 | [Lê Nguyễn Phú Hải] | Lập trình Frontend:  Cổng Khách hàng (Đánh giá, Khảo sát),Cổng Quản trị Admin Server & Phân hệ Quản lý CRM Manager (Chart.js, Báo cáo). | 100% | 10 / 10 | |

#### Bảng Kế hoạch Làm việc Chi tiết (Tiến độ 15 tuần):
* **Tuần 1 – Tuần 2:** Nhận đề tài từ Khoa CNTT SGU, họp nhóm phân chia vai trò, xác định phạm vi chọn phân hệ CRM (Mục III.4).
* **Tuần 3 – Tuần 4:** Khảo sát mô hình doanh nghiệp thương mại SGU Tech JSC, xây dựng bảng câu hỏi điều tra 15 câu, tổng hợp kết quả.
* **Tuần 5 – Tuần 6:** Viết bài toán mô tả chi tiết hoạt động HTTT, phân tích phân rã chức năng (vẽ sơ đồ BFD).
* **Tuần 7 – Tuần 8:** Xây dựng mô hình dữ liệu DFD (Sơ đồ ngữ cảnh và DFD mức đỉnh Level 0), xác định các kho dữ liệu.
* **Tuần 9 – Tuần 10:** Thiết kế CSDL quan hệ 9 bảng, chuẩn hóa 3NF, viết kịch bản Backup / Restore. Lập trình Backend Web API (.NET 8.0).
* **Tuần 11 – Tuần 12:** Lập trình Frontend tách biệt 3 cổng: Admin Server, Quản lý CRM và Cổng Khách hàng Storefront.
* **Tuần 13 – Tuần 14:** Nạp dữ liệu mẫu demo, kiểm thử chức năng, tối ưu hóa giao diện doanh nghiệp thực thụ.
* **Tuần 15:** Hoàn tất báo cáo in ấn, đóng gói source code, file script SQL và chuẩn bị bảo vệ đồ án.

---

## PHẦN I: PHẦN CHUNG & KHẢO SÁT HỆ THỐNG THÔNG TIN (10 ĐIỂM)

### 1. Giới thiệu Doanh nghiệp
* **Tên doanh nghiệp:** CÔNG TY CỔ PHẦN CÔNG NGHỆ THƯƠNG MẠI SGU TECH (SGU TECH COMMERCIAL JSC).
* **Mã số thuế:** 0318941065.
* **Trụ sở chính:** 273 An Dương Vương, Phường 3, Quận 5, TP. Hồ Chí Minh.
* **Lĩnh vực hoạt động:** Bán buôn, bán lẻ thiết bị công nghệ thông tin (Laptop AI, linh kiện máy tính, màn hình độ phân giải cao, thiết bị mạng, phụ kiện gaming gear) và cung cấp giải pháp chuyển đổi số cho doanh nghiệp.
* **Mô hình nhân sự và cơ cấu tổ chức:**
  1. *Ban Giám đốc (Board of Directors):* Định hướng chiến lược kinh doanh.
  2. *Bộ phận Quản trị Hệ thống (IT & Admin Server):* Đảm bảo hạ tầng máy chủ, sao lưu CSDL, phân quyền tài khoản người dùng nội bộ.
  3. *Bộ phận Quản lý Khách hàng (CRM & Marketing):* Tiếp nhận ý kiến khách hàng, xử lý khiếu nại, phân tích nhân khẩu học (độ tuổi, sở thích), thực hiện khảo sát thăm dò thị trường trước khi nhập sản phẩm mới.
  4. *Bộ phận Kinh doanh & Bán hàng (Sales):* Tư vấn sản phẩm, xử lý đơn hàng.
  5. *Bộ phận Kho vận (Warehouse):* Nhập, xuất, lưu trữ và bảo quản nguyên vật liệu/thành phẩm.
  6. *Khách hàng (Customers):* Đối tượng tương tác trực tiếp với doanh nghiệp để trải nghiệm, đánh giá chất lượng sản phẩm và tham gia khảo sát.

---

### 2. Khảo sát Hệ thống Thông tin của Doanh nghiệp
Nhóm đã tiến hành điều tra, khảo sát thực tế tại doanh nghiệp với **bộ 15 câu hỏi chuyên sâu** bám sát quy trình HTTT:

| STT | Câu hỏi khảo sát HTTT | Đối tượng khảo sát | Mục đích khảo sát |
| :---: | :--- | :--- | :--- |
| **Q01** | Hiện tại doanh nghiệp đang lưu trữ thông tin khách hàng bằng phương tiện gì (Sổ sách, Excel hay phần mềm)? | Ban Quản lý | Đánh giá mức độ số hóa dữ liệu hiện tại. |
| **Q02** | Khách hàng phản hồi về chất lượng sản phẩm qua những kênh nào và thời gian phản hồi trung bình là bao lâu? | CSKH / Khách hàng | Khảo sát điểm nghẽn trong khâu chăm sóc khách hàng. |
| **Q03** | Doanh nghiệp có gặp khó khăn gì khi phân loại sở thích và độ tuổi của khách hàng để nhập sản phẩm mới không? | Bộ phận Marketing | Xác định nhu cầu về module Báo cáo nhân khẩu học. |
| **Q04** | Khi chuẩn bị nhập một dòng sản phẩm công nghệ mới giá trị cao, doanh nghiệp thăm dò thị trường bằng cách nào? | Trưởng phòng CRM | Khảo sát nhu cầu xây dựng chức năng Khảo sát trực tuyến. |
| **Q05** | Hệ thống hiện tại có phân quyền tách biệt giữa nhân viên kỹ trị (Admin) và nhân viên nghiệp vụ (CRM Manager) không? | Quản trị IT | Đánh giá tính an toàn thông tin và bảo mật. |
| **Q06** | Dữ liệu tài khoản của người dùng nội bộ và khách hàng có được mã hóa và bảo vệ tránh rò rỉ không? | Quản trị IT | Đảm bảo tính bảo mật mật khẩu (BCrypt hashing). |
| **Q07** | Doanh nghiệp đã có kịch bản sao lưu dữ liệu dự phòng (Backup) định kỳ để phòng chống sự cố mất dữ liệu chưa? | Quản trị IT | Khảo sát phương án an toàn dữ liệu và phục hồi. |
| **Q08** | Khách hàng có thể tự đăng ký, đăng nhập và tự chỉnh sửa hồ sơ thông tin cá nhân của mình trên hệ thống không? | Khách hàng | Đánh giá tính tiện ích của Cổng thông tin khách hàng. |
| **Q09** | Khách hàng có thể xem lại câu trả lời giải đáp từ phía quản lý đối với phản hồi của họ hay không? | Khách hàng | Đánh giá tính minh bạch và tương tác hai chiều. |
| **Q10** | Người quản lý có công cụ trực quan hóa (Biểu đồ) để theo dõi tỷ lệ hài lòng (số sao 1-5) theo từng ngày không? | Quản lý CRM | Xác định yêu cầu thiết kế Dashboard & Chart.js. |
| **Q11** | Khi khảo sát sản phẩm mới, hệ thống có hỗ trợ thiết lập thời hạn kết thúc để tự động đóng khảo sát không? | Quản lý CRM | Yêu cầu quản lý vòng đời bài khảo sát (ExpiresAt). |
| **Q12** | Doanh nghiệp có cần tính năng khóa tài khoản ngay lập tức khi phát hiện khách hàng có hành vi bất thường không? | Quản lý CRM | Đánh giá tính năng kiểm soát tài khoản (Toggle Active). |
| **Q13** | Thời gian phản hồi của trang web khi có nhiều người cùng truy cập vào xem danh mục sản phẩm là bao lâu? | Khách hàng / Dev | Đánh giá hiệu năng và tính ổn định hệ thống. |
| **Q14** | Doanh nghiệp có mong muốn phân loại khách hàng theo nhóm sở thích (Gaming, Văn phòng, Lập trình, Đồ họa) không? | Marketing / CRM | Xây dựng tiêu chí phân khúc dữ liệu khách hàng. |
| **Q15** | Giải pháp mới có cần khả năng mở rộng để kết nối thêm phân hệ Bán hàng (Sales) và Kho (Warehouse) sau này không? | Ban Giám đốc | Xác định kiến trúc mở của hệ thống thông tin. |

#### Tổng kết kết quả khảo sát & Kết luận cho HTTT:
* **Hiện trạng bất cập:** Doanh nghiệp đang quản lý phản hồi rải rác qua mạng xã hội, chưa có cơ sở dữ liệu tập trung, việc thống kê độ tuổi/sở thích làm thủ công bằng Excel mất nhiều ngày, không thăm dò được ý định mua của khách hàng trước khi nhập lô hàng mới.
* **Kết luận giải pháp:** Cần thiết phải xây dựng một **Hệ thống Thông tin Doanh nghiệp hiện đại**, trong đó module cốt lõi là **Phân hệ CRM tương tác hai chiều**:
  1. *Cổng Admin:* Chuyên trách quản trị tài khoản, cấp quyền, sao lưu CSDL an toàn.
  2. *Cổng Quản lý CRM:* Trực quan hóa độ hài lòng, tiếp nhận/giải đáp phản hồi, phát hành và thống kê khảo sát sản phẩm mới.
  3. *Cổng Khách hàng:* Trải nghiệm danh mục sản phẩm, gửi đánh giá minh bạch, tham gia khảo sát đóng góp ý kiến và quản lý hồ sơ cá nhân.

---

## PHẦN II: PHÂN TÍCH HỆ THỐNG THÔNG TIN DOANH NGHIỆP (10 ĐIỂM)

### 1. Bài toán Mô tả Chi tiết Nghiệp vụ HTTT Doanh nghiệp
Doanh nghiệp SGU Tech hoạt động phân phối thiết bị công nghệ. Hoạt động của HTTT bao gồm:
1. **Quản trị Máy chủ & Tài khoản (Admin Server):**
   - Admin đăng nhập vào cổng quản trị nội bộ bảo mật.
   - Admin có quyền tạo mới tài khoản cho nhân viên (cấp quyền Admin, Quản lý CRM, hoặc Khách hàng).
   - Admin có thể thay đổi vai trò (Role) của bất kỳ tài khoản nào, khóa/mở khóa tài khoản khi có vi phạm, hoặc xóa tài khoản. Dữ liệu khi xóa được hệ thống dọn dẹp liên kết tránh xung đột khóa ngoại.
   - Quản trị viên theo dõi toàn bộ danh mục sản phẩm và nhà cung cấp để đồng bộ số liệu kho vận.

2. **Nghiệp vụ Quản lý Khách hàng (CRM Management):**
   - Người quản lý CRM theo dõi danh sách toàn bộ khách hàng của doanh nghiệp. Quản lý có thể thêm khách hàng mới hoặc khóa tài khoản của khách hàng khi cần thiết.
   - Khi khách hàng gửi đánh giá về sản phẩm, phản hồi được đưa vào hàng đợi *"Chờ xử lý"*. Quản lý CRM đọc nội dung, nhập lời giải đáp chính thức từ doanh nghiệp, trạng thái chuyển thành *"Đã tiếp nhận & Xử lý"*.
   - Hệ thống tự động tổng hợp hồ sơ nhân khẩu học, vẽ biểu đồ phân loại theo các nhóm tuổi (<20 tuổi, 20–30 tuổi, >30 tuổi) và sở thích tiêu dùng (Gaming, Văn phòng, Đồ họa, Lập trình).
   - Khi doanh nghiệp chuẩn bị ra mắt một sản phẩm công nghệ mới (ví dụ Laptop AI thế hệ mới), Quản lý phát hành một bài khảo sát kèm mô tả, giá dự kiến và thời hạn (số ngày hoặc ngày kết thúc cụ thể). Khảo sát được tự động chuyển đến toàn bộ tài khoản khách hàng.
   - Quản lý theo dõi bảng thống kê kết quả khảo sát: tổng số lượt trả lời, điểm đánh giá trung bình (1–5 sao), tỷ lệ ý định mua (*Rất muốn mua, Đang cân nhắc, Không mua*) và các ý kiến đóng góp về tính năng/mức giá.

3. **Nghiệp vụ Khách hàng (Customer Experience):**
   - Khách hàng có thể tự đăng ký tài khoản mới và đăng nhập vào Cổng thông tin khách hàng.
   - Khách hàng xem danh mục sản phẩm kinh doanh, chọn sản phẩm để gửi đánh giá chất lượng (1–5 sao) và nhận xét. Khách hàng cũng xem được câu trả lời từ phía Quản lý và các đánh giá khác của cộng đồng.
   - Khách hàng nhận được danh sách bài khảo sát sản phẩm mới từ doanh nghiệp, tham gia cho điểm mức độ quan tâm, lựa chọn ý định mua và gửi phản hồi đóng góp. Mỗi khách hàng chỉ được làm mỗi bài khảo sát 1 lần; bài khảo sát hết hạn sẽ tự động khóa.
   - Khách hàng có quyền xem và cập nhật lại thông tin cá nhân (Họ tên, SĐT, Tuổi, Địa chỉ, Sở thích) bất kỳ lúc nào.

---

### 2. Sơ đồ Phân rã Chức năng (BFD - Business Function Diagram) (2 điểm)

![Sơ đồ Phân rã Chức năng BFD](images/bfd_diagram.png)

*Hình 2.1: Sơ đồ Phân rã Chức năng (Business Function Diagram - BFD) Hệ thống SGU Tech*

**Giải thích chi tiết 3 phân hệ chức năng:**
1. **1.0 Phân hệ Admin Server:** Quản trị kỹ thuật tập trung gồm: Thêm tài khoản mới (1.1), Xóa & Khóa/Mở tài khoản (1.2), Phân quyền trực tiếp Role (1.3), Tách biệt hoàn toàn cổng quản lý nhân sự, kho, bán hàng và lược bỏ xem/lọc SP/NCC theo yêu cầu đề bài; Quản lý kịch bản sao lưu & phục hồi CSDL (1.4).
2. **2.0 Phân hệ Người Quản lý (CRM):** Thực hiện đầy đủ 7 nghiệp vụ: Thêm một khách hàng mới (2.1), Xóa khách hàng (2.2), Khóa tài khoản khách hàng (2.3), Tiếp nhận & giải đáp phản hồi (2.4), Báo cáo nhân khẩu học độ tuổi & sở thích (2.5), Tạo bảng khảo sát gửi đến TK khách hàng (2.6) và Thống kê kết quả khảo sát (2.7).
3. **3.0 Phân hệ Cổng Khách hàng (Portal):** Thực hiện 5 chức năng: Đăng ký tài khoản (3.1), Đăng nhập (3.2), Chỉnh sửa thông tin cá nhân (3.3), Gửi phản hồi sản phẩm kèm bộ lọc thông minh (3.4) và Nhận/thực hiện khảo sát sản phẩm mới 5 tiêu chí (3.5).

---

### 3. Sơ đồ Ngữ cảnh (Context Diagram - DFD Mức 0 Cảnh) (2 điểm)

![Sơ đồ Ngữ cảnh Context Diagram](images/context_diagram.png)

*Hình 2.2: Sơ đồ Ngữ cảnh (Context Diagram) Hệ thống Thông tin Doanh nghiệp SGU Tech*

**Mô tả các luồng thông tin vào/ra với 3 tác nhân ngoài:**
* **Quản trị viên (Admin Server):**
  - *Luồng vào:* Thông tin tạo tài khoản, lệnh phân quyền (Role Assignment), lệnh khóa/xóa tài khoản.
  - *Luồng ra:* Trạng thái tài khoản, báo cáo phân quyền, nhật ký sao lưu và trạng thái an toàn CSDL.
* **Người quản lý CRM (Manager):**
  - *Luồng vào:* Hồ sơ khách hàng mới, lệnh khóa/xóa khách hàng, nội dung giải đáp phản hồi sản phẩm, bài khảo sát sản phẩm mới kèm thời hạn kết thúc.
  - *Luồng ra:* Danh sách phản hồi cần giải đáp, báo cáo phân loại độ tuổi & sở thích, bảng thống kê tỷ lệ ý định mua và điểm đánh giá trung bình.
* **Khách hàng (Customer):**
  - *Luồng vào:* Thông tin đăng ký tài khoản, hồ sơ cá nhân cập nhật, đánh giá sản phẩm (1–5 sao và nhận xét), kết quả trả lời khảo sát 5 chiều.
  - *Luồng ra:* Thông báo xác thực đăng nhập, danh mục sản phẩm kinh doanh, câu trả lời giải đáp từ Quản lý và danh sách phiếu khảo sát sản phẩm mới.

---

### 4. Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD) (4 điểm)

![Sơ đồ Luồng Dữ liệu Mức Đỉnh Level 0 DFD](images/dfd_level0_diagram.png)

*Hình 2.3: Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD) với 5 Tiến trình và 5 Kho dữ liệu (D1–D5)*

**Mô tả ma trận 5 Tiến trình và 5 Kho dữ liệu:**

| Tiến trình / Kho DL | Tên thành phần | Tác nhân tương tác | Kho dữ liệu liên quan | Mô tả nghiệp vụ dữ liệu |
| :--- | :--- | :--- | :--- | :--- |
| **Tiến trình 1.0** | Quản trị Hệ thống & Phân quyền | Admin Server | D1: Accounts & Roles | Thêm tài khoản, gán quyền Role, khóa và xóa an toàn khóa ngoại. |
| **Tiến trình 2.0** | Quản lý Khách hàng & Báo cáo | Người quản lý CRM | D1, D2: CustomerProfiles | Thêm/Xóa/Khóa KH; kết xuất biểu đồ cơ cấu độ tuổi và sở thích tiêu dùng. |
| **Tiến trình 3.0** | Tiếp nhận & Giải đáp Phản hồi | Khách hàng, Quản lý CRM | D3: Products, D4: Feedbacks | Ghi nhận đánh giá 1-5 sao của KH; lưu nội dung giải đáp từ Quản lý CRM. |
| **Tiến trình 4.0** | Khảo sát Sản phẩm Mới & Thống kê | Người quản lý CRM, Khách hàng | D5: Surveys & Responses | Phát hành khảo sát có thời hạn; thu thập câu trả lời và tính toán thống kê. |
| **Tiến trình 5.0** | Cổng Tương tác Khách hàng | Khách hàng | D1, D2, D3, D4, D5 | Xử lý đăng ký, đăng nhập, tra cứu sản phẩm và chỉnh sửa hồ sơ cá nhân. |
| **Kho D1** | Kho Tài khoản & Phân quyền | Admin, Quản lý, KH | Bảng Accounts, Roles | Lưu trữ định danh người dùng và vai trò bảo mật. |
| **Kho D2** | Kho Hồ sơ Khách hàng | Quản lý CRM, KH | Bảng CustomerProfiles | Lưu trữ dữ liệu nhân khẩu học: tuổi, giới tính, sở thích, địa chỉ. |
| **Kho D3** | Kho Hàng hóa & Đối tác | Khách hàng, Admin | Products, Categories, Suppliers | Lưu trữ thông tin sản phẩm công nghệ và danh mục kinh doanh. |
| **Kho D4** | Kho Đánh giá Phản hồi | Khách hàng, Quản lý CRM | Bảng Feedbacks | Lưu trữ nội dung đánh giá 1-5 sao và phản hồi từ phía doanh nghiệp. |
| **Kho D5** | Kho Khảo sát & Ý kiến thị trường | Quản lý CRM, KH | Surveys, SurveyResponses | Lưu trữ các bài khảo sát sản phẩm mới và kết quả phản hồi của khách hàng. |

---

## PHẦN III: THIẾT KẾ HỆ THỐNG THÔNG TIN (10 ĐIỂM)

### 1. Thiết kế Cơ sở Dữ liệu Quan hệ Thực thể & Bảng Từ điển Dữ liệu (5 điểm)

Dựa trên 5 kho dữ liệu D1 – D5 đã phân tích ở sơ đồ DFD mức đỉnh, Cơ sở dữ liệu của Hệ thống Thông tin Doanh nghiệp SGU Tech được chuẩn hóa đạt dạng chuẩn 3 (3NF) gồm 8 bảng quan hệ thực thể chặt chẽ:

![Lược đồ CSDL Quan hệ Thực thể ERD](images/erd_diagram.png)

*Hình 3.1: Lược đồ Cơ sở Dữ liệu Quan hệ Thực thể (Relational Schema / ERD) Chuẩn hóa 3NF*

Hệ thống được thiết kế chuẩn hóa gồm **9 bảng quan hệ chặt chẽ**:

#### 1. Bảng `Roles` (Vai trò người dùng)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `RoleId` | INT | **PK** | IDENTITY(1,1) | Mã định danh vai trò |
| `RoleName` | NVARCHAR(50) | | NOT NULL, UNIQUE | Tên vai trò chuẩn hệ thống (Admin, Manager, Customer) |
| `Description`| NVARCHAR(250)| | NULL | Mô tả quyền hạn trong hệ thống |

#### 2. Bảng `Accounts` (Tài khoản người dùng)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `AccountId` | INT | **PK** | IDENTITY(1,1) | Mã định danh tài khoản |
| `Username` | VARCHAR(50) | | NOT NULL, UNIQUE | Tên đăng nhập hệ thống |
| `PasswordHash`| NVARCHAR(255)| | NOT NULL | Mật khẩu mã hóa / đối chiếu an toàn |
| `FullName` | NVARCHAR(100)| | NOT NULL | Họ và tên người dùng |
| `Email` | VARCHAR(100) | | NULL | Địa chỉ thư điện tử |
| `Phone` | VARCHAR(20) | | NULL | Số điện thoại liên hệ |
| `RoleId` | INT | **FK** | REFERENCES Roles(RoleId) | Phân quyền tài khoản |
| `IsActive` | BIT | | NOT NULL, DEFAULT 1 | Trạng thái (1: Hoạt động, 0: Đã khóa) |
| `CreatedAt` | DATETIME | | NOT NULL, DEFAULT GETDATE() | Thời điểm tạo tài khoản |

#### 3. Bảng `Categories` (Danh mục sản phẩm)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `CategoryId` | INT | **PK** | IDENTITY(1,1) | Mã danh mục |
| `CategoryName`| NVARCHAR(100)| | NOT NULL | Tên danh mục sản phẩm |
| `Description` | NVARCHAR(255)| | NULL | Ghi chú mô tả nhóm hàng |

#### 4. Bảng `Suppliers` (Nhà cung cấp)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `SupplierId` | INT | **PK** | IDENTITY(1,1) | Mã nhà cung cấp |
| `SupplierCode`| VARCHAR(20) | | NOT NULL, UNIQUE | Mã ký hiệu NCC (NCC001, ...) |
| `SupplierName`| NVARCHAR(150)| | NOT NULL | Tên công ty/nhà phân phối |
| `ContactName` | NVARCHAR(100)| | NULL | Người liên hệ đại diện |
| `Phone` | VARCHAR(20) | | NULL | Số điện thoại đối tác |
| `Address` | NVARCHAR(255)| | NULL | Địa chỉ trụ sở nhà cung cấp |

#### 5. Bảng `Products` (Sản phẩm kinh doanh)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `ProductId` | INT | **PK** | IDENTITY(1,1) | Mã sản phẩm |
| `ProductCode` | VARCHAR(50) | | NOT NULL, UNIQUE | Mã hàng hóa (SP001, SP002, ...) |
| `ProductName` | NVARCHAR(200)| | NOT NULL | Tên sản phẩm thương mại |
| `CategoryId` | INT | **FK** | REFERENCES Categories | Danh mục trực thuộc |
| `SupplierId` | INT | **FK** | REFERENCES Suppliers | Đơn vị cung cấp |
| `Price` | DECIMAL(18,2)| | NOT NULL | Đơn giá bán niêm yết (VNĐ) |
| `CostPrice` | DECIMAL(18,2)| | NOT NULL | Giá vốn nhập hàng |
| `StockQuantity`| INT | | NOT NULL, DEFAULT 0 | Số lượng tồn kho thực tế |
| `Unit` | NVARCHAR(20) | | NOT NULL | Đơn vị tính (Cái, Bộ) |
| `Status` | NVARCHAR(50) | | NOT NULL | Trạng thái (Đang bán, Hết hàng) |
| `ImageUrl` | NVARCHAR(500)| | NULL | Đường dẫn ảnh sản phẩm sắc nét |

#### 6. Bảng `CustomerProfiles` (Hồ sơ khách hàng - Mục 4.1.5)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `ProfileId` | INT | **PK** | IDENTITY(1,1) | Mã hồ sơ khách hàng |
| `AccountId` | INT | **FK** | UNIQUE, REFERENCES Accounts ON DELETE CASCADE | Khóa ngoại liên kết tài khoản |
| `Age` | INT | | NOT NULL | Độ tuổi khách hàng |
| `Gender` | NVARCHAR(10) | | NULL | Giới tính (Nam, Nữ, Khác) |
| `Address` | NVARCHAR(255)| | NULL | Địa chỉ cư trú |
| `Interest` | NVARCHAR(100)| | NULL | Sở thích (Gaming, Văn phòng, Đồ họa, Lập trình) |

#### 7. Bảng `Feedbacks` (Phản hồi & Đánh giá sản phẩm - Mục 4.1.4 & 4.3.3)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `FeedbackId` | INT | **PK** | IDENTITY(1,1) | Mã phản hồi |
| `AccountId` | INT | **FK** | REFERENCES Accounts ON DELETE CASCADE | Khách hàng thực hiện đánh giá |
| `ProductId` | INT | **FK** | REFERENCES Products ON DELETE CASCADE | Sản phẩm được nhận xét |
| `Rating` | INT | | CHECK (Rating >= 1 AND <= 5) | Số sao đánh giá độ hài lòng |
| `Comment` | NVARCHAR(1000)| | NOT NULL | Nội dung nhận xét chi tiết |
| `AdminReply` | NVARCHAR(1000)| | NULL | Câu trả lời chính thức từ doanh nghiệp |
| `Status` | NVARCHAR(50) | | DEFAULT N'Chờ xử lý' | Trạng thái xử lý phản hồi |
| `CreatedAt` | DATETIME | | NOT NULL, DEFAULT GETDATE() | Thời gian gửi nhận xét |

#### 8. Bảng `Surveys` (Khảo sát sản phẩm mới - Mục 4.1.6)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `SurveyId` | INT | **PK** | IDENTITY(1,1) | Mã khảo sát |
| `Title` | NVARCHAR(200)| | NOT NULL | Tiêu đề chương trình khảo sát |
| `Description` | NVARCHAR(1000)| | NULL | Mô tả tính năng công nghệ mới |
| `TargetProduct`| NVARCHAR(150)| | NOT NULL | Tên sản phẩm chuẩn bị ra mắt |
| `ExpectedPrice`| DECIMAL(18,2)| | NOT NULL | Giá bán dự kiến (VNĐ) |
| `CreatedAt` | DATETIME | | NOT NULL, DEFAULT GETDATE() | Ngày phát hành khảo sát |
| `IsActive` | BIT | | NOT NULL, DEFAULT 1 | Trạng thái (1: Đang mở, 0: Đã khóa) |
| `ExpiresAt` | DATETIME | | NULL | Thời hạn kết thúc khảo sát |

#### 9. Bảng `SurveyResponses` (Kết quả trả lời khảo sát - Mục 4.1.7 & 4.3.4)
| Tên cột | Kiểu dữ liệu | Khóa | Ràng buộc | Mô tả |
| :--- | :--- | :---: | :--- | :--- |
| `ResponseId` | INT | **PK** | IDENTITY(1,1) | Mã kết quả trả lời |
| `SurveyId` | INT | **FK** | REFERENCES Surveys ON DELETE CASCADE | Khảo sát tương ứng |
| `AccountId` | INT | **FK** | REFERENCES Accounts ON DELETE CASCADE | Khách hàng tham gia |
| `Score` | INT | | CHECK (Score >= 1 AND <= 5) | Điểm quan tâm đối với sản phẩm |
| `BuyingIntent` | NVARCHAR(50) | | NOT NULL | Ý định mua (Rất muốn mua, Đang cân nhắc, Không mua) |
| `CustomerOpinion`| NVARCHAR(1000)| | NULL | Ý kiến góp ý về giá và tính năng |
| `SubmittedAt` | DATETIME | | NOT NULL, DEFAULT GETDATE() | Thời điểm gửi khảo sát |

---

### 2. Thiết kế Giao diện, Hình ảnh Minh chứng và Giới thiệu Chi tiết Chức năng (Mục I.3.b - 5 điểm)

Hệ thống được thiết kế theo kiến trúc chuẩn doanh nghiệp công nghệ hiện đại (Enterprise Architecture), lấy cảm hứng từ phong cách tập đoàn VNG Corporation với tông màu thương hiệu cam công nghệ (`#FF5B00`), xanh doanh nghiệp (`#1E3A8A`), bố cục thẻ card thoáng đạt, trực quan và **tách biệt hoàn toàn (Strict Role Separation)** giữa các vai trò:

#### 1. Giao diện Phân hệ Quản trị Hệ thống - Admin Server (`admin.html` - Mục II.2):
* **Nguyên tắc thiết kế tách biệt:** Giao diện Admin Server hoàn toàn tách biệt với giao diện của Quản lý Nhân sự (HR), Quản lý Kho (Warehouse), Quản lý Bán hàng (Sales) và Người Quản lý Khách hàng (Manager). Chức năng xem/tìm kiếm/lọc sản phẩm và nhà cung cấp đã được lược bỏ khỏi Admin theo đúng yêu cầu đề bài.
* **Chức năng thực hiện:** Admin quản lý danh sách toàn bộ tài khoản; bảng quản trị thông minh gộp thông tin người dùng vào cột định danh chuyên nghiệp; hỗ trợ Thêm mới account (kèm phân quyền), Phân quyền trực tiếp bằng Dropdown phân vai trò (`PUT /api/admin/accounts/{id}/role`), Khóa/Mở khóa tài khoản ngay lập tức và Xóa tài khoản an toàn toàn vẹn dữ liệu.

![Giao diện Admin Server](images/ui_admin_server.jpg)
*Hình 3.2: Giao diện Phân hệ Quản trị Hệ thống - Admin Server (Quản lý tài khoản, phân quyền, khóa và xóa)*

#### 2. Giao diện Phân hệ Người Quản lý CRM (`manager_crm.html` - Mục III.4.1):
Thực hiện trọn vẹn 7 chức năng theo đúng yêu cầu của Người quản lý:
1. **Thêm một khách hàng mới:** Form thêm khách hàng nhập họ tên, username, mật khẩu, SĐT, email, độ tuổi, giới tính và sở thích tiêu dùng.
2. **Xóa khách hàng:** Nút xóa an toàn, dọn dẹp các ràng buộc khóa ngoại liên quan.
3. **Khóa tài khoản khách hàng:** Nút khóa/mở khóa tức thì trạng thái `IsActive` để chặn đăng nhập khi có vi phạm.
4. **Tiếp nhận phản hồi của khách hàng:** Theo dõi đánh giá 1-5 sao của khách hàng theo từng mã sản phẩm; nhập nội dung giải đáp chính thức từ quản lý.
5. **Báo cáo khách hàng, tỷ lệ độ tuổi & sở thích:** Tự động thống kê với 2 biểu đồ trực quan Chart.js (Độ tuổi: `<20`, `20-30`, `>30`; Sở thích: `Gaming`, `Văn phòng`, `Đồ họa`, `Lập trình`).
6. **Tạo bảng khảo sát gửi đến TK khách hàng:** Phát hành bài khảo sát kèm mô tả, giá dự kiến và thời hạn; phân phối tự động tới tài khoản khách hàng.
7. **Thống kê kết quả khảo sát:** Tab độc lập hiển thị biểu đồ phân bố điểm quan tâm 1-5 sao, tỷ lệ ý định mua sắm và bảng chi tiết câu trả lời.

![Giao diện Người Quản lý CRM](images/ui_manager_crm.png)
*Hình 3.3: Giao diện Người Quản lý CRM (Quản lý khách hàng, theo dõi chỉ số và thực hiện 7 nghiệp vụ CRM)*

#### 3. Giao diện Trang chủ Cổng Khách hàng & Cổng Đăng nhập / Đăng ký (`user.html` & `customer_login.html`):
* **Trang chủ phong cách VNG Corporation:** Hero Banner nhận diện thương hiệu công nghệ hiện đại; bộ 3 Thẻ điều hướng danh tiếng (Sản phẩm - Products, Khảo sát - People, Đánh giá - Impacts) giúp khách hàng truy cập nhanh các dịch vụ.
* **Đăng ký & Đăng nhập tối giản:** Giao diện đăng nhập và đăng ký được thiết kế riêng biệt tại `customer_login.html`, form tinh gọn, trực quan, hỗ trợ khách hàng tạo tài khoản chỉ trong vài giây.

![Giao diện Trang chủ Cổng Khách hàng](images/ui_guide_user_full.png)
*Hình 3.4: Giao diện Trang chủ Cổng Khách hàng SGU Tech Store (Thiết kế phong cách VNG với 3 thẻ điều hướng thương hiệu)*

![Cổng Đăng nhập & Đăng ký Khách hàng](images/ui_guide_cust_login.png)
*Hình 3.5: Cổng Đăng nhập & Đăng ký Khách hàng tối giản, chuyên nghiệp*

#### 4. Giao diện Gửi Phản hồi Sản phẩm & Bộ lọc Thông minh (`user.html` - Mục III.4.3 - Chức năng 4):
* **Gửi đánh giá chất lượng:** Khách hàng chọn sản phẩm, chấm điểm 1–5 sao và nhập nhận xét chi tiết.
* **Bộ lọc phản hồi thông minh (Smart Filter Toolbar):** Thay thế hoàn toàn dropdown truyền thống bằng thanh công cụ tìm kiếm trực tiếp + các nút lọc danh mục (Laptop, Màn hình, Bàn phím, Linh kiện) + nút lọc đánh giá 5★ và phản hồi đã được Quản lý giải đáp.

![Giao diện Gửi phản hồi sản phẩm và Bộ lọc thông minh](images/ui_customer_feedback.jpg)
*Hình 3.6: Giao diện Gửi phản hồi sản phẩm và Bộ lọc đánh giá thông minh*

#### 5. Biểu mẫu Thực hiện Khảo sát 5 Tiêu chí & Chỉnh sửa Thông tin Cá nhân (`user.html` - Mục III.4.3 - Chức năng 3 & 5):
* **Phiếu khảo sát thị trường 5 chiều chuyên sâu:** Gồm 5 tiêu chí khảo sát toàn diện: (1) Thang điểm quan tâm 1-5 sao dạng Card tương tác; (2) Đánh giá mức giá (Rẻ, Hợp lý, Hơi cao, Quá đắt); (3) Chọn tính năng mong đợi dạng thẻ Chip; (4) Ý định mua & Thời điểm xuống tiền; (5) Mức giá sẵn sàng chi trả kèm góp ý chi tiết.
* **Chỉnh sửa thông tin tài khoản:** Khách hàng dễ dàng xem thẻ thành viên và cập nhật Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích và Địa chỉ.

![Biểu mẫu Khảo sát sản phẩm mới](images/ui_customer_survey.jpg)
*Hình 3.7: Biểu mẫu Khảo sát sản phẩm mới với 5 tiêu chí thăm dò thị trường chuyên nghiệp*

![Giao diện Chỉnh sửa thông tin hồ sơ cá nhân](images/ui_customer_profile.jpg)
*Hình 3.8: Giao diện Chỉnh sửa thông tin hồ sơ cá nhân của khách hàng*

---

### 3. Kịch bản Sao lưu và Phục hồi Cơ sở Dữ liệu (Backup & Restore - Mục II.1 - 5 điểm)

Doanh nghiệp xây dựng quy chế sao lưu an toàn CSDL trên Microsoft SQL Server như sau:
1. **Sao lưu toàn phần (Full Backup):** Thực hiện định kỳ vào 00:00 Chủ Nhật hàng tuần:
   ```sql
   BACKUP DATABASE [HTTTDN_DB]
   TO DISK = N'C:\Backup\HTTTDN_DB_Full.bak'
   WITH FORMAT, INIT, NAME = N'HTTTDN_DB - Full Database Backup', STATS = 10;
   ```
2. **Sao lưu vi sai (Differential Backup):** Thực hiện vào 23:00 mỗi ngày trong tuần:
   ```sql
   BACKUP DATABASE [HTTTDN_DB]
   TO DISK = N'C:\Backup\HTTTDN_DB_Diff.bak'
   WITH DIFFERENTIAL, NAME = N'HTTTDN_DB - Differential Backup', STATS = 10;
   ```
3. **Phục hồi Cơ sở Dữ liệu khi có sự cố (Restore Database):**
   ```sql
   USE master;
   ALTER DATABASE [HTTTDN_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   RESTORE DATABASE [HTTTDN_DB]
   FROM DISK = N'C:\Backup\HTTTDN_DB_Full.bak'
   WITH REPLACE, RECOVERY;
   ALTER DATABASE [HTTTDN_DB] SET MULTI_USER;
   ```

---

## PHẦN IV: CÀI ĐẶT, BẢO TRÌ & HƯỚNG DẪN SỬ DỤNG HỆ THỐNG (5 ĐIỂM)

### 1. Phương án Cài đặt & Chuyển đổi Hệ thống
* **Phương án chuyển đổi được chọn:** **Chuyển đổi song song (Parallel Conversion)** kết hợp **Chuyển đổi theo giai đoạn (Phased Conversion)**.
  - *Giai đoạn 1:* Vận hành song song hệ thống mới cùng file theo dõi Excel cũ trong 4 tuần để đối chiếu tính chính xác của dữ liệu phản hồi và thông tin tài khoản.
  - *Giai đoạn 2:* Khi toàn bộ nhân viên và khách hàng đã làm quen với giao diện Cổng thông tin web mới, doanh nghiệp ngắt hoàn toàn hệ thống cũ và chuyển 100% giao dịch sang HTTT SGU Tech.

### 2. Tài liệu Hướng dẫn Cài đặt & Khởi chạy Phần mềm
* **Yêu cầu môi trường:** Máy tính chạy Windows 10/11, cài sẵn .NET 8.0 SDK và trình duyệt web hiện đại (Edge, Chrome).
* **Bước 1:** Khởi động Backend Web API:
  - Mở PowerShell tại thư mục `/Backend/HTTTDN.AdminApi`, gõ lệnh:
    ```powershell
    dotnet run
    ```
  - Hệ thống tự động tạo CSDL SQLite `htttdn.db` với đầy đủ 9 bảng và dữ liệu mẫu phong phú. Máy chủ lắng nghe tại `http://localhost:5000`.
* **Bước 2:** Khởi chạy Giao diện Frontend:
  - Mở thư mục `/Frontend_Admin` bằng Visual Studio Code.
  - Chuột phải vào file `login.html`, chọn **Open with Live Server** (chạy tại cổng 5500).

### 3. Hướng dẫn Sử dụng Chi tiết Theo Vai trò (Minh họa 100% bằng Hình ảnh Thực tế của Đồ án)

Dưới đây là tài liệu hướng dẫn vận hành chi tiết cho 3 nhóm đối tượng người dùng, minh họa bằng ảnh chụp thực tế từ các phân hệ của đồ án:

#### 3.1. Hướng dẫn Vận hành Dành cho Quản trị viên (Admin Server):
* **Bước 1 - Đăng nhập nội bộ:** Quản trị viên mở trang `login.html`, nhập tài khoản `admin` và mật khẩu `123456`. Hệ thống kiểm tra mật khẩu mã hóa BCrypt và điều hướng vào Cổng Quản trị.

![Cổng Đăng nhập Quản trị Nội bộ](images/ui_guide_login.png)
*Hình 4.1: Cổng Đăng nhập Hệ thống Quản trị Nội bộ dành riêng cho Admin và Quản lý*

* **Bước 2 - Thao tác Quản trị Tài khoản & Phân quyền:** Trên giao diện `admin.html`, Quản trị viên theo dõi 4 thẻ chỉ số KPI, bấm nút "+ Thêm tài khoản" để cấp tài khoản mới, chọn quyền trực tiếp từ Dropdown (Admin, Manager, Customer), bấm "Khóa" để tạm ngưng truy cập hoặc bấm "Xóa Account" để thu hồi tài khoản.

![Giao diện Tác nghiệp Admin Server](images/ui_guide_admin.png)
*Hình 4.2: Giao diện Tác nghiệp của Admin Server — Quản lý Danh sách Tài khoản & Phân quyền trực tiếp*

#### 3.2. Hướng dẫn Vận hành Dành cho Người Quản lý (CRM Manager):
* **Bước 1 - Đăng nhập phân hệ CRM:** Người quản lý đăng nhập tại `login.html` với tài khoản `quanly` / `123456`. Hệ thống tự động phân luồng và mở giao diện `manager_crm.html`.
* **Bước 2 - Thực hiện 7 Nghiệp vụ CRM:**
  - *Tab 1 (Hồ sơ Khách hàng):* Thực hiện: (1) Bấm nút "+ Thêm một khách hàng mới" để nhập hồ sơ thành viên; (2) Bấm "Xóa" để xóa khách hàng; (3) Bấm "Khóa" để chặn đăng nhập tài khoản vi phạm.
  - *Tab 2 (Tiếp nhận Phản hồi):* (4) Xem phản hồi đánh giá sản phẩm 1–5 sao của khách hàng, nhập câu trả lời giải đáp chính thức từ doanh nghiệp.
  - *Tab 3 (Báo cáo Nhân khẩu học):* (5) Xem biểu đồ tỷ lệ độ tuổi (<20, 20-30, >30) và tỷ lệ sở thích (Gaming, Văn phòng, Đồ họa, Lập trình).
  - *Tab 4 (Khảo sát Thị trường):* (6) Bấm "+ Tạo khảo sát mới", nhập tên sản phẩm, giá dự kiến, thời hạn kết thúc để tự động phân phối phiếu khảo sát tới tài khoản khách hàng.
  - *Tab 5 (Thống kê Kết quả):* (7) Theo dõi trực quan tỷ lệ ý định mua sắm, điểm số quan tâm trung bình và danh sách ý kiến đóng góp của khách hàng.

![Giao diện Người Quản lý CRM](images/ui_manager_crm.png)
*Hình 4.3: Giao diện Người Quản lý CRM — Thực hiện 7 nghiệp vụ quản lý khách hàng và thống kê*

#### 3.3. Hướng dẫn Sử dụng Dành cho Khách hàng (Customer Portal):
* **Bước 1 - Đăng ký & Đăng nhập:** Khách hàng truy cập `customer_login.html` (tách biệt hoàn toàn cổng nội bộ). Khách hàng có thể tự đăng ký tài khoản với form tối giản hoặc đăng nhập bằng tài khoản `khachhang1` / `123456`.

![Cổng Đăng nhập và Đăng ký Khách hàng](images/ui_guide_cust_login.png)
*Hình 4.4: Cổng Đăng nhập và Đăng ký Tài khoản Khách hàng SGU Tech Store*

* **Bước 2 - Trải nghiệm Trang chủ SGU Tech Store:** Giao diện trang chủ `user.html` được thiết kế theo phong cách doanh nghiệp công nghệ VNG với Hero Banner nhận diện và 3 Thẻ điều hướng danh tiếng (Products - People - Impacts).

![Giao diện Trang chủ Cổng Khách hàng](images/ui_guide_user_full.png)
*Hình 4.5: Giao diện Trang chủ Cổng Khách hàng SGU Tech Store (Phong cách Tập đoàn VNG)*

* **Bước 3 - Gửi Đánh giá Sản phẩm & Bộ lọc Thông minh:** Khách hàng chọn sản phẩm, chấm 1–5 sao và gửi nhận xét. Bảng theo dõi phản hồi tích hợp Smart Filter Toolbar giúp lọc nhanh theo danh mục (Laptop, Màn hình, Bàn phím, Linh kiện) hoặc lọc đánh giá 5★ và xem lời giải đáp từ Người quản lý.

![Thao tác Gửi phản hồi sản phẩm](images/ui_customer_feedback.jpg)
*Hình 4.6: Thao tác Gửi phản hồi sản phẩm và Theo dõi lời giải đáp từ Người quản lý*

* **Bước 4 - Thực hiện Khảo sát Sản phẩm Mới 5 Tiêu chí:** Khi doanh nghiệp phát hành khảo sát, khách hàng bấm "Thực hiện khảo sát" để tham gia đánh giá theo 5 tiêu chí: Điểm quan tâm 1-5, Đánh giá mức giá, Chọn tính năng mong đợi dạng thẻ Chip, Ý định mua sắm & thời điểm, Mức giá sẵn sàng chi trả kèm góp ý.

![Thao tác Thực hiện khảo sát](images/ui_customer_survey.jpg)
*Hình 4.7: Thao tác Thực hiện bảng khảo sát sản phẩm mới với 5 tiêu chí thăm dò thị trường*

* **Bước 5 - Chỉnh sửa Thông tin Hồ sơ Cá nhân:** Khách hàng xem thẻ thành viên và cập nhật Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích và Địa chỉ. Dữ liệu này tự động đồng bộ sang báo cáo nhân khẩu học của Người quản lý CRM.

![Chỉnh sửa thông tin hồ sơ cá nhân](images/ui_customer_profile.jpg)
*Hình 4.8: Thao tác Chỉnh sửa thông tin hồ sơ cá nhân của khách hàng*

---

## PHẦN V: TỔNG KẾT VÀ HƯỚNG PHÁT TRIỂN HỆ THỐNG (5 ĐIỂM)

### 1. Những kết quả đã đạt được
* Xây dựng thành công toàn diện Hệ thống Thông tin Doanh nghiệp SGU Tech bám sát 100% đề bài của Khoa CNTT - SGU.
* Thiết kế CSDL 9 bảng chuẩn hóa cao, bảo toàn toàn vẹn dữ liệu, có kịch bản Backup/Restore.
* Giao diện phân tách mạch lạc 3 cổng (Admin Server, Quản lý CRM, Cổng Khách hàng) với ngôn ngữ thiết kế doanh nghiệp công nghệ tiên tiến (lấy cảm hứng từ hệ sinh thái VNG Tech & tập đoàn lớn): Tông cam công nghệ đặc trưng (#FF5B00), thanh điều hướng tinh tế, bộ 3 thẻ điều hướng VNG tương tác (Sản phẩm, Khảo sát, Hồ sơ) và form đăng ký tối giản 3 trường cơ bản, mang lại trải nghiệm hiện đại, mượt mà và trực quan.
* Chức năng khảo sát có thời hạn và thống kê trực quan phản ánh đúng thực tế thăm dò thị trường của doanh nghiệp thương mại.

### 2. Ưu điểm & Hạn chế
* **Ưu điểm:** Tốc độ phản hồi cực nhanh, hỗ trợ cả cơ chế SQLite tự động chạy ngay lẫn SQL Server Enterprise phục vụ bảo vệ đồ án, hỗ trợ phím Enter tiện lợi, bảo mật mật khẩu.
* **Hạn chế:** Chưa tích hợp cổng thanh toán trực tuyến ngân hàng (VNPAY/Momo) và chưa có module gửi thông báo đẩy qua Email tự động.

### 3. Hướng phát triển trong tương lai
* Mở rộng thêm 2 phân hệ **Quản lý Kho (MRP - Mục III.5)** và **Quản trị Nhân sự (HRM - Mục III.3)** để tạo thành bộ giải pháp hoạch định nguồn lực doanh nghiệp (ERP) toàn diện.
* Tích hợp Trí tuệ nhân tạo (AI Recommendation) gợi ý sản phẩm dựa trên lịch sử đánh giá và nhóm sở thích của khách hàng.
* Triển khai hệ thống lên nền tảng đám mây (Cloud Server) để phục vụ khách hàng trên toàn quốc.

---
**XÁC NHẬN CỦA NHÓM SINH VIÊN THỰC HIỆN**
*(Ký và ghi rõ họ tên)*

