const CRM_API = "http://localhost:5000/api/admin/crm";

// Offline Canvas Chart.js Fallback (đảm bảo hiển thị biểu đồ ngay cả khi không có Internet)
if (typeof window.Chart === "undefined") {
    window.Chart = class OfflineChart {
        constructor(ctx, config) {
            this.ctx = ctx;
            this.canvas = ctx.canvas;
            this.config = config;
            this.render();
        }
        destroy() {
            if (this.ctx && this.canvas) {
                this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            }
        }
        render() {
            const canvas = this.canvas;
            const parent = canvas.parentElement;
            const w = (parent && parent.clientWidth > 100) ? parent.clientWidth : 520;
            const h = (parent && parent.clientHeight > 80) ? parent.clientHeight : 250;
            canvas.width = w;
            canvas.height = h;
            const ctx = this.ctx;
            ctx.clearRect(0, 0, w, h);
            ctx.font = "600 12px 'Segoe UI', Inter, sans-serif";

            const labels = this.config?.data?.labels || [];
            const ds = (this.config?.data?.datasets && this.config.data.datasets[0]) || { data: [], backgroundColor: [] };
            const values = ds.data || [];
            const colors = Array.isArray(ds.backgroundColor) ? ds.backgroundColor : ["#FF6A00", "#2563EB", "#059669", "#7C3AED", "#F59E0B"];

            if (this.config.type === "bar") {
                const padL = 45, padR = 20, padT = 25, padB = 42;
                const chartW = w - padL - padR;
                const chartH = h - padT - padB;
                const maxVal = Math.max(...values, 4);

                ctx.strokeStyle = "#E2E8F0";
                ctx.lineWidth = 1;
                for (let i = 0; i <= 4; i++) {
                    const y = padT + chartH - (i / 4) * chartH;
                    ctx.beginPath();
                    ctx.moveTo(padL, y);
                    ctx.lineTo(w - padR, y);
                    ctx.stroke();
                    ctx.fillStyle = "#64748B";
                    ctx.textAlign = "right";
                    ctx.fillText(Math.round((i / 4) * maxVal), padL - 8, y + 4);
                }

                const step = chartW / Math.max(labels.length, 1);
                const barW = Math.min(44, step * 0.55);
                labels.forEach((lbl, idx) => {
                    const val = values[idx] || 0;
                    const bh = (val / maxVal) * chartH;
                    const x = padL + idx * step + (step - barW) / 2;
                    const y = padT + chartH - bh;
                    ctx.fillStyle = colors[idx % colors.length] || "#FF6A00";
                    ctx.beginPath();
                    ctx.roundRect ? ctx.roundRect(x, y, barW, bh, 5) : ctx.rect(x, y, barW, bh);
                    ctx.fill();

                    ctx.fillStyle = "#0F172A";
                    ctx.textAlign = "center";
                    ctx.font = "700 12px 'Segoe UI', sans-serif";
                    ctx.fillText(String(val), x + barW / 2, y - 6);

                    ctx.fillStyle = "#334155";
                    ctx.font = "600 11.5px 'Segoe UI', sans-serif";
                    const shortLbl = String(lbl).length > 16 ? String(lbl).substring(0, 15) + "…" : String(lbl);
                    ctx.fillText(shortLbl, x + barW / 2, padT + chartH + 20);
                });
            } else {
                // Doughnut / Pie chart
                const total = values.reduce((a, b) => a + Number(b || 0), 0) || 1;
                const cx = Math.min(w * 0.34, 150);
                const cy = h / 2;
                const rOut = Math.min(cx - 20, cy - 20, 88);
                const rIn = rOut * 0.56;
                let startAngle = -Math.PI / 2;

                values.forEach((v, idx) => {
                    const slice = (Number(v || 0) / total) * Math.PI * 2;
                    ctx.beginPath();
                    ctx.moveTo(cx, cy);
                    ctx.arc(cx, cy, rOut, startAngle, startAngle + slice);
                    ctx.closePath();
                    ctx.fillStyle = colors[idx % colors.length] || "#2563EB";
                    ctx.fill();
                    startAngle += slice;
                });

                ctx.beginPath();
                ctx.arc(cx, cy, rIn, 0, Math.PI * 2);
                ctx.fillStyle = "#FFFFFF";
                ctx.fill();

                ctx.fillStyle = "#0F172A";
                ctx.textAlign = "center";
                ctx.font = "800 16px 'Segoe UI', sans-serif";
                ctx.fillText(String(total), cx, cy + 5);

                const legX = cx + rOut + 26;
                let legY = Math.max(28, cy - (labels.length * 24) / 2);
                ctx.textAlign = "left";
                labels.forEach((lbl, idx) => {
                    const v = values[idx] || 0;
                    const pct = Math.round((v / total) * 100);
                    ctx.fillStyle = colors[idx % colors.length] || "#2563EB";
                    ctx.fillRect(legX, legY - 10, 12, 12);
                    ctx.fillStyle = "#1E293B";
                    ctx.font = "600 12px 'Segoe UI', sans-serif";
                    const cleanLbl = String(lbl).length > 28 ? String(lbl).substring(0, 27) + "…" : String(lbl);
                    ctx.fillText(`${cleanLbl}: ${v} (${pct}%)`, legX + 18, legY);
                    legY += 24;
                });
            }
        }
    };
}

let currentViewedSurveyId = null;
let crmStarChart = null;
let crmProdChart = null;
let agePieChartInstance = null;
let interestBarChartInstance = null;
let surveyIntentChartInstance = null;
let surveyScoreChartInstance = null;

const FALLBACK_CUSTOMERS = [
    { accountId: 5, username: "khachhang1", fullName: "Nguyễn Văn An", email: "an.nguyen@gmail.com", phone: "0912345671", isActive: true, profile: { age: 19, gender: "Nam", interest: "Gaming", address: "273 An Dương Vương, Quận 5, TP.HCM" } },
    { accountId: 6, username: "khachhang2", fullName: "Lê Thị Bình", email: "binh.le@gmail.com", phone: "0912345672", isActive: true, profile: { age: 24, gender: "Nữ", interest: "Văn phòng", address: "120 Nguyễn Thị Minh Khai, Quận 3, TP.HCM" } },
    { accountId: 7, username: "khachhang3", fullName: "Phạm Minh Châu", email: "chau.pham@gmail.com", phone: "0912345673", isActive: true, profile: { age: 27, gender: "Nam", interest: "Đồ họa", address: "45 Lê Lợi, Quận 1, TP.HCM" } },
    { accountId: 8, username: "khachhang4", fullName: "Hoàng Đức Dũng", email: "dung.hoang@gmail.com", phone: "0912345674", isActive: true, profile: { age: 35, gender: "Nam", interest: "Gaming", address: "88 Nguyễn Văn Linh, Quận 7, TP.HCM" } },
    { accountId: 9, username: "khachhang5", fullName: "Võ Ngọc Hân (Tài khoản vi phạm - Đã khóa)", email: "han.vo@gmail.com", phone: "0912345675", isActive: false, profile: { age: 22, gender: "Nữ", interest: "Văn phòng", address: "15 Võ Văn Ngân, TP. Thủ Đức" } },
    { accountId: 10, username: "khachhang6", fullName: "Trần Quốc Bảo", email: "bao.tran@gmail.com", phone: "0912345676", isActive: true, profile: { age: 18, gender: "Nam", interest: "Gaming", address: "90 Cách Mạng Tháng 8, Quận 10, TP.HCM" } },
    { accountId: 11, username: "khachhang7", fullName: "Đặng Thúy Kiều", email: "kieu.dang@gmail.com", phone: "0912345677", isActive: true, profile: { age: 32, gender: "Nữ", interest: "Đồ họa", address: "212 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM" } },
    { accountId: 12, username: "khachhang8", fullName: "Vũ Tuấn Kiệt", email: "kiet.vu@gmail.com", phone: "0912345678", isActive: true, profile: { age: 25, gender: "Nam", interest: "Lập trình", address: "102 Tô Hiến Thành, Quận 10, TP.HCM" } },
    { accountId: 13, username: "khachhang9", fullName: "Bùi Quỳnh Chi", email: "chi.bui@gmail.com", phone: "0912345679", isActive: true, profile: { age: 21, gender: "Nữ", interest: "Đồ họa", address: "56 Phan Xích Long, Quận Phú Nhuận, TP.HCM" } },
    { accountId: 14, username: "khachhang10", fullName: "Đỗ Hoàng Long", email: "long.do@gmail.com", phone: "0912345680", isActive: true, profile: { age: 29, gender: "Nam", interest: "Lập trình", address: "310 Hoàng Văn Thụ, Quận Tân Bình, TP.HCM" } },
    { accountId: 15, username: "khachhang11", fullName: "Ngô Phương Thảo", email: "thao.ngo@gmail.com", phone: "0912345681", isActive: true, profile: { age: 26, gender: "Nữ", interest: "Văn phòng", address: "18 Nguyễn Huệ, Quận 1, TP.HCM" } },
    { accountId: 16, username: "khachhang12", fullName: "Trịnh Gia Huy", email: "huy.trinh@gmail.com", phone: "0912345682", isActive: true, profile: { age: 17, gender: "Nam", interest: "Gaming", address: "74 Kinh Dương Vương, Quận 6, TP.HCM" } },
    { accountId: 17, username: "khachhang13", fullName: "Mai Anh Tuấn", email: "tuan.mai@gmail.com", phone: "0912345683", isActive: true, profile: { age: 38, gender: "Nam", interest: "Lập trình", address: "199 Nam Kỳ Khởi Nghĩa, Quận 3, TP.HCM" } },
    { accountId: 18, username: "khachhang14", fullName: "Dương Hoàng Yến", email: "yen.duong@gmail.com", phone: "0912345684", isActive: true, profile: { age: 33, gender: "Nữ", interest: "Văn phòng", address: "25 Lê Văn Việt, TP. Thủ Đức" } },
    { accountId: 19, username: "khachhang15", fullName: "Phan Thành Đạt (Tạm ngưng giao dịch)", email: "dat.phan@gmail.com", phone: "0912345685", isActive: false, profile: { age: 28, gender: "Nam", interest: "Gaming", address: "145 Quang Trung, Quận Gò Vấp, TP.HCM" } }
];

const FALLBACK_FEEDBACKS = [
    { feedbackId: 1, customerName: "Nguyễn Văn An", productName: "Laptop ASUS ROG Strix G16 (i9-14900HX / RTX 4070)", rating: 5, comment: "Laptop ASUS ROG chạy rất mượt, tản nhiệt mát, màn hình 240Hz chơi game cực kỳ sắc nét!", adminReply: "Cảm ơn bạn An đã tin tưởng lựa chọn dòng ROG tại SGU Tech! Chúc bạn có những giờ phút trải nghiệm tuyệt vời.", status: "Đã tiếp nhận & xử lý" },
    { feedbackId: 2, customerName: "Lê Thị Bình", productName: "Chuột không dây công thái học Logitech MX Master 3S", rating: 4, comment: "Chuột MX Master 3S cầm rất êm tay, cuộn siêu nhanh nhưng giao hàng hơi trễ 1 buổi chiều.", adminReply: "Dạ SGU Tech xin ghi nhận góp ý về khâu vận chuyển của chị Bình và đã tặng kèm mã giảm giá 10% cho đơn tiếp theo ạ!", status: "Đã tiếp nhận & xử lý" },
    { feedbackId: 3, customerName: "Phạm Minh Châu", productName: "Màn hình đồ họa ASUS ProArt 27 inch 4K HDR IPS", rating: 5, comment: "Màn hình ProArt chuẩn màu Delta E < 2 tuyệt đối, dựng phim và chỉnh ảnh cực kỳ chuẩn xác.", adminReply: "Cảm ơn anh Châu! Dòng ASUS ProArt luôn được cân chỉnh màu tại nhà máy trước khi xuất xưởng ạ.", status: "Đã tiếp nhận & xử lý" },
    { feedbackId: 4, customerName: "Hoàng Đức Dũng", productName: "Bàn phím cơ Gaming Logitech G Pro X TKL Wireless", rating: 3, comment: "Bàn phím cơ G Pro X gõ đầm tay nhưng phần mềm G-Hub cài đặt hơi phức tạp với người mới.", adminReply: "", status: "Chờ xử lý" },
    { feedbackId: 5, customerName: "Trần Quốc Bảo", productName: "Màn hình Gaming LG UltraGear 27 inch 2K 180Hz", rating: 5, comment: "Màn hình LG UltraGear tần số quét 180Hz bắn CS2 và Valorant siêu mượt, không có bóng mờ.", adminReply: "", status: "Chờ xử lý" },
    { feedbackId: 6, customerName: "Vũ Tuấn Kiệt", productName: "Laptop Apple MacBook Pro 14 M3 Pro (18GB / 512GB)", rating: 5, comment: "MacBook Pro M3 Pro biên dịch Docker và chạy máy ảo mượt mà, pin dùng cả ngày ở quán cafe.", adminReply: "Cảm ơn anh Kiệt đã ủng hộ dòng MacBook chính hãng tại SGU Tech!", status: "Đã tiếp nhận & xử lý" },
    { feedbackId: 7, customerName: "Bùi Quỳnh Chi", productName: "Bàn phím cơ Custom Keychron Q1 Max Nhôm CNC", rating: 5, comment: "Khung nhôm CNC của Keychron Q1 Max nặng đầm tay, âm gõ thocky nghe cực kỳ thích tai.", adminReply: "Cảm ơn bạn Chi! Keychron Q1 Max hiện đang là mẫu bàn phím custom bán chạy nhất tại cửa hàng ạ.", status: "Đã tiếp nhận & xử lý" },
    { feedbackId: 8, customerName: "Đỗ Hoàng Long", productName: "Màn hình chuyên đồ họa Dell UltraSharp 32 inch 4K", rating: 4, comment: "Màn hình Dell UltraSharp 32 inch không gian hiển thị rộng rãi, cổng Type-C sạc luôn cho laptop rất tiện.", adminReply: "Cảm ơn anh Long đã phản hồi tích cực về dòng màn hình cao cấp Dell UltraSharp!", status: "Đã tiếp nhận & xử lý" },
    { feedbackId: 9, customerName: "Ngô Phương Thảo", productName: "Tai nghe chống ồn không dây Sony WH-1000XM5 Hi-Res", rating: 5, comment: "Chống ồn của Sony XM5 thực sự đỉnh cao, đeo làm việc trong văn phòng cả ngày không bị đau tai.", adminReply: "", status: "Chờ xử lý" },
    { feedbackId: 10, customerName: "Hoàng Đức Dũng", productName: "Card đồ họa ASUS TUF Gaming GeForce RTX 4080 Super", rating: 2, comment: "Card đồ họa RTX 4080 Super giao đến bị cấn một góc hộp bìa carton bên ngoài do vận chuyển.", adminReply: "SGU Tech chân thành xin lỗi anh về sự cố khâu vận chuyển! Quản lý kho đã liên hệ và đổi mới nguyên seal cho anh ngay trong hôm nay ạ.", status: "Đã tiếp nhận & xử lý" }
];

const FALLBACK_SURVEYS = [
    { surveyId: 1, title: "Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026", description: "Đánh giá nhu cầu trang bị chip NPU AI chuyên dụng, màn hình OLED 3K và thời lượng pin 20 tiếng.", targetProduct: "ASUS Zenbook S16 OLED AI", expectedPrice: 36990000, isActive: true, isExpired: false, expiresAt: "2026-12-30T00:00:00", totalResponses: 6, totalCustomerAccounts: 13 },
    { surveyId: 2, title: "Khảo sát Bàn phím cơ Custom Nhôm CNC Không dây", description: "Thăm dò ý kiến khách hàng về mẫu bàn phím cơ khung nhôm CNC nguyên khối, mạch Hotswap RGB 3 chế độ kết nối.", targetProduct: "Keychron Q1 Pro Wireless Special", expectedPrice: 4590000, isActive: true, isExpired: false, expiresAt: null, totalResponses: 4, totalCustomerAccounts: 13 },
    { surveyId: 3, title: "Khảo sát Màn hình Đồ họa 5K Chuyên Nghiệp", description: "Khảo sát nhu cầu sử dụng màn hình độ phân giải 5K chuẩn màu 99% DCI-P3 kết nối Thunderbolt 4.", targetProduct: "Dell UltraSharp 27 5K U2725QE", expectedPrice: 21500000, isActive: true, isExpired: false, expiresAt: "2026-12-15T00:00:00", totalResponses: 3, totalCustomerAccounts: 13 },
    { surveyId: 4, title: "Thăm dò Tai nghe chống ồn Hi-Res Thế hệ Mới", description: "Khảo sát tính năng khử tiếng ồn chủ động bằng AI và thời lượng pin 40 giờ.", targetProduct: "Sony WH-1000XM6 Edition 2026", expectedPrice: 9490000, isActive: true, isExpired: false, expiresAt: "2026-12-25T00:00:00", totalResponses: 2, totalCustomerAccounts: 13 },
    { surveyId: 5, title: "Khảo sát Màn hình cong Mini-LED 49 inch (Đã kết thúc)", description: "Chương trình khảo sát đợt 1 đã hết thời gian nhận phản hồi.", targetProduct: "Samsung Odyssey Neo G9 49 inch", expectedPrice: 32990000, isActive: false, isExpired: true, expiresAt: "2026-11-01T00:00:00", totalResponses: 1, totalCustomerAccounts: 13 }
];

let allCustomersCache = FALLBACK_CUSTOMERS;
let allFeedbacksCache = FALLBACK_FEEDBACKS;
let allSurveysCache = FALLBACK_SURVEYS;
let allSurveyResponsesCache = [];
let selectedFeedbackId = null;
let selectedSurveyResponseId = null;
let replyTargetType = "feedback"; // "feedback" | "survey"

const DEFAULT_SURVEY_REQUIREMENTS = [
    { text: "Yêu cầu đánh giá mức độ quan tâm & thiết kế sản phẩm", checked: true },
    { text: "Yêu cầu thẩm định mức giá dự kiến & ngân sách chi trả", checked: true },
    { text: "Yêu cầu khảo sát cấu hình kỹ thuật & tính năng ưu tiên", checked: true },
    { text: "Yêu cầu khảo sát chính sách ưu đãi & bảo hành hậu mãi", checked: true },
    { text: "Yêu cầu xác định kế hoạch mua sắm & đề xuất cải tiến", checked: true }
];

function getDefaultSurveyQuestionsTemplate() {
    return [
        {
            id: 1,
            requirement: "Yêu cầu đánh giá mức độ quan tâm",
            question: "Mức độ quan tâm và hào hứng của bạn đối với sản phẩm mới này?",
            type: "rating",
            required: true,
            options: ["1 - Rất thờ ơ", "2 - Ít quan tâm", "3 - Bình thường", "4 - Khá quan tâm", "5 - Rất hào hứng"]
        },
        {
            id: 2,
            requirement: "Yêu cầu thẩm định mức giá dự kiến",
            question: "Bạn đánh giá thế nào về mức giá dự kiến mở bán so với công nghệ mang lại?",
            type: "single",
            required: true,
            options: ["Giá rất hợp lý / Đáng đầu tư", "Mức giá hơi cao nhưng chấp nhận được", "Mức giá quá đắt / Cần giảm thêm", "Chưa phù hợp với ngân sách"]
        },
        {
            id: 3,
            requirement: "Yêu cầu khảo sát tính năng & cấu hình",
            question: "Những tiêu chí kỹ thuật & tính năng nào bạn yêu cầu bắt buộc phải có trên sản phẩm?",
            type: "multi",
            required: true,
            options: ["Hiệu năng mạnh mẽ vượt trội", "Thời lượng pin bền bỉ & Sạc nhanh", "Thiết kế mỏng nhẹ cao cấp", "Tích hợp công nghệ AI thông minh", "Màn hình chuẩn màu độ phân giải cao", "Tản nhiệt êm ái & Bền bỉ"]
        },
        {
            id: 4,
            requirement: "Yêu cầu chính sách ưu đãi & hậu mãi",
            question: "Chính sách ưu đãi hoặc dịch vụ hậu mãi nào bạn mong muốn nhất khi mở bán?",
            type: "multi",
            required: true,
            options: ["Trả góp 0% lãi suất", "Bảo hành VIP 1 đổi 1 trong 24 tháng", "Tặng kèm bộ phụ kiện chính hãng", "Trợ giá thu cũ đổi mới lên đời", "Voucher giảm giá trực tiếp đợt đầu"]
        },
        {
            id: 5,
            requirement: "Yêu cầu xác định kế hoạch mua sắm",
            question: "Kế hoạch và ý định mua sắm của bạn khi sản phẩm chính thức mở bán tại SGU Tech?",
            type: "single",
            required: true,
            options: ["Rất muốn mua (Đặt trước Pre-order ngay)", "Đang cân nhắc (Chờ xem đánh giá thực tế)", "Đang cân nhắc (Đợi đợt khuyến mãi giảm giá)", "Không mua (Chưa có nhu cầu)"]
        },
        {
            id: 6,
            requirement: "Yêu cầu đề xuất mức giá & góp ý riêng",
            question: "Mức giá bạn sẵn sàng chi trả và các yêu cầu / góp ý chi tiết khác cho sản phẩm:",
            type: "text",
            required: false,
            options: []
        }
    ];
}

let builderRequirements = JSON.parse(JSON.stringify(DEFAULT_SURVEY_REQUIREMENTS));
let builderQuestions = getDefaultSurveyQuestionsTemplate();

const syncChannel = new BroadcastChannel("htttdn_realtime_sync");

function notifyDataChanged(scope) {
    const payload = { scope, timestamp: Date.now() };
    syncChannel.postMessage(payload);
    localStorage.setItem("htttdn_sync_event", JSON.stringify(payload));
}

syncChannel.onmessage = () => refreshCrmDataSilently();
window.addEventListener("storage", (e) => {
    if (e.key === "htttdn_sync_event") refreshCrmDataSilently();
});
window.addEventListener("focus", () => refreshCrmDataSilently());

window.onload = async () => {
    let user = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!user || user.roleName !== "Manager") {
        user = {
            id: 3,
            username: "quanly",
            fullName: "Trần Trưởng Phòng CRM",
            roleName: "Manager"
        };
        localStorage.setItem("currentUser", JSON.stringify(user));
    }
    const mgrEl = document.getElementById("managerName");
    if (mgrEl) {
        mgrEl.innerText = `${user.fullName} (${user.username})`;
    }
    renderSurveyRequirementsBuilder();
    renderInlineSurveyQuestionsBuilder();
    await refreshCrmDataSilently();

    const params = new URLSearchParams(window.location.search);
    const tabParam = params.get("tab");
    if (tabParam) {
        const navBtn = document.querySelector(`button[onclick*="${tabParam}"]`);
        switchTab(tabParam, navBtn);
    }
};

async function refreshCrmDataSilently() {
    try {
        await Promise.all([
            loadCustomers(),
            loadSurveys(),
            loadSurveyResponses(),
            loadFeedbacks(),
            loadDemographics()
        ]);
        if (currentViewedSurveyId && allSurveysCache.some(s => s.surveyId === currentViewedSurveyId)) {
            await viewSurveyStats(currentViewedSurveyId, true);
        } else if (allSurveysCache.length > 0) {
            await viewSurveyStats(allSurveysCache[0].surveyId, true);
        }
    } catch (err) {
        console.error("Lỗi refreshCrmDataSilently:", err);
    }
}

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));
    const target = document.getElementById(id);
    if (target) target.style.display = "block";
    if (btn) btn.classList.add("active");

    const breadcrumbMap = {
        tabCustomers: "Hồ sơ Khách hàng",
        tabFeedbacks: "Tiếp nhận Phản hồi",
        tabDemographics: "Báo cáo Nhân khẩu học",
        tabSurveys: "Khảo sát Thị trường",
        tabSurveyStats: "Thống kê Kết quả"
    };
    const bEl = document.getElementById("mgrBreadcrumb");
    if (bEl && breadcrumbMap[id]) {
        bEl.innerText = breadcrumbMap[id];
    }

    if (id === "tabFeedbacks") {
        setTimeout(loadFeedbacks, 50);
    } else if (id === "tabDemographics") {
        setTimeout(loadDemographics, 50);
    } else if (id === "tabSurveyStats") {
        const targetSurveyId = currentViewedSurveyId || (allSurveysCache[0]?.surveyId);
        if (targetSurveyId) {
            setTimeout(() => viewSurveyStats(targetSurveyId, false), 50);
        }
    }
}

// =========================================================
// 1. QUẢN LÝ KHÁCH HÀNG: THÊM MỚI, XÓA, KHÓA TÀI KHOẢN KH
// =========================================================
async function loadCustomers() {
    try {
        const res = await fetch(`${CRM_API}/customers`);
        if (res.ok) {
            allCustomersCache = await res.json();
        }
    } catch (e) {
        console.warn("Sử dụng dữ liệu khách hàng dự phòng:", e);
    }

    const total = allCustomersCache.length;
    const activeCount = allCustomersCache.filter(c => c.isActive).length;
    const lockedCount = total - activeCount;

    if (document.getElementById("cusKpiTotal")) document.getElementById("cusKpiTotal").innerText = total;
    if (document.getElementById("cusKpiActive")) document.getElementById("cusKpiActive").innerText = activeCount;
    if (document.getElementById("cusKpiLocked")) document.getElementById("cusKpiLocked").innerText = lockedCount;

    filterCustomerList();
    renderSurveyRecipientCheckboxes();
    renderDemographicsCustomerTable();
}

function filterCustomerList() {
    const kw = document.getElementById("cusSearchInput")?.value.trim().toLowerCase() || "";
    const ageFilter = document.getElementById("cusFilterAge")?.value || "";
    const interestFilter = document.getElementById("cusFilterInterest")?.value || "";
    const statusFilter = document.getElementById("cusFilterStatus")?.value || "";

    const filtered = allCustomersCache.filter(c => {
        if (kw) {
            const uMatch = c.username && c.username.toLowerCase().includes(kw);
            const nMatch = c.fullName && c.fullName.toLowerCase().includes(kw);
            const pMatch = c.phone && c.phone.includes(kw);
            if (!uMatch && !nMatch && !pMatch) return false;
        }

        const age = c.profile?.age || 0;
        if (ageFilter === "under20" && age >= 20) return false;
        if (ageFilter === "20to30" && (age < 20 || age > 30)) return false;
        if (ageFilter === "over30" && age <= 30) return false;

        if (interestFilter && c.profile?.interest !== interestFilter) return false;
        if (statusFilter === "active" && !c.isActive) return false;
        if (statusFilter === "locked" && c.isActive) return false;

        return true;
    });

    renderCustomersTable(filtered);
}

function resetCustomerFilter() {
    document.getElementById("cusSearchInput").value = "";
    document.getElementById("cusFilterAge").value = "";
    document.getElementById("cusFilterInterest").value = "";
    if (document.getElementById("cusFilterStatus")) document.getElementById("cusFilterStatus").value = "";
    renderCustomersTable(allCustomersCache);
}

function renderCustomersTable(list) {
    const badgeEl = document.getElementById("cusCountBadge");
    if (badgeEl) badgeEl.innerText = `Đang hiển thị ${list.length} / ${allCustomersCache.length} khách hàng`;

    const tbody = document.getElementById("customerList");
    if (!tbody) return;

    if (list.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8" style="text-align:center; padding:20px; color:var(--text-muted);">Không tìm thấy khách hàng nào khớp bộ lọc.</td></tr>`;
        return;
    }

    tbody.innerHTML = list.map(c => {
        const age = c.profile?.age || 0;
        let ageLabel = "-";
        if (age > 0) {
            if (age < 20) ageLabel = `${age} tuổi <span class="badge-tag" style="background:#dbeafe; color:#1e40af;">&lt; 20 tuổi</span>`;
            else if (age <= 30) ageLabel = `${age} tuổi <span class="badge-tag" style="background:#e0e7ff; color:#3730a3;">20 - 30 tuổi</span>`;
            else ageLabel = `${age} tuổi <span class="badge-tag" style="background:#fef3c7; color:#92400e;">&gt; 30 tuổi</span>`;
        }

        let interestTag = "-";
        if (c.profile?.interest) {
            const intColors = {
                "Gaming": "background:#fee2e2; color:#991b1b;",
                "Văn phòng": "background:#e0f2fe; color:#0369a1;",
                "Đồ họa": "background:#f3e8ff; color:#6b21a8;",
                "Lập trình": "background:#dcfce7; color:#166534;"
            };
            const style = intColors[c.profile.interest] || "background:#f1f5f9; color:#334155;";
            interestTag = `<span class="badge-tag" style="${style}">${c.profile.interest}</span>`;
        }

        return `
            <tr>
                <td>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <div class="user-avatar-circle" style="width:28px; height:28px; font-size:11px; background:#059669;">
                            ${(c.username || "KH").substring(0, 2).toUpperCase()}
                        </div>
                        <b>${c.username}</b>
                    </div>
                </td>
                <td><b style="color:var(--text-primary);">${c.fullName}</b></td>
                <td>
                    <div>${c.phone || "-"}</div>
                    <small style="color:var(--text-muted);">${c.email || ""}</small>
                </td>
                <td>${ageLabel}</td>
                <td>${interestTag}</td>
                <td><small style="color:var(--text-muted);">${c.profile?.address || "TP. Hồ Chí Minh"}</small></td>
                <td><span class="badge ${c.isActive ? 'badge-active' : 'badge-locked'}">${c.isActive ? 'Hoạt động' : 'Đã khóa TK'}</span></td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn btn-warning" style="padding:5px 10px; font-size:12px;" onclick="toggleLock(${c.accountId})">
                            ${c.isActive ? 'Khóa TK' : 'Mở khóa TK'}
                        </button>
                        <button class="btn btn-danger" style="padding:5px 10px; font-size:12px;" onclick="deleteCustomer(${c.accountId})">
                            Xóa KH
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

// THÊM MỘT KHÁCH HÀNG MỚI (TRỰC TIẾP TRÊN KHUNG NHANH)
async function submitQuickAddCustomer() {
    const username = document.getElementById("qCusUser").value.trim();
    const password = document.getElementById("qCusPass").value.trim() || "123456";
    const fullName = document.getElementById("qCusName").value.trim();
    if (!username || !fullName) {
        return alert("Vui lòng nhập đầy đủ Tài khoản (Username) và Họ tên khách hàng!");
    }

    const body = {
        username,
        password,
        fullName,
        phone: document.getElementById("qCusPhone").value.trim(),
        age: Number(document.getElementById("qCusAge").value || 22),
        gender: document.getElementById("qCusGender").value,
        interest: document.getElementById("qCusInterest").value,
        address: document.getElementById("qCusAddress").value.trim() || "TP. Hồ Chí Minh"
    };

    try {
        const res = await fetch(`${CRM_API}/customers`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Không thể thêm khách hàng.");

        alert(data.message || "Đã thêm một khách hàng mới thành công!");
        document.getElementById("qCusUser").value = "";
        document.getElementById("qCusName").value = "";
        document.getElementById("qCusPhone").value = "";
        document.getElementById("qCusAddress").value = "";
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi thêm khách hàng: " + err.message);
    }
}

function openAddCustomerModal() {
    document.getElementById("cUser").value = "";
    document.getElementById("cName").value = "";
    document.getElementById("cPhone").value = "";
    document.getElementById("cAge").value = "22";
    document.getElementById("cGender").value = "Nam";
    document.getElementById("cInterest").value = "Gaming";
    document.getElementById("cAddress").value = "";
    document.getElementById("customerModal").classList.add("show");
}

function closeCustomerModal() {
    document.getElementById("customerModal").classList.remove("show");
}

async function submitAddCustomerModal() {
    const username = document.getElementById("cUser").value.trim();
    const fullName = document.getElementById("cName").value.trim();
    if (!username || !fullName) return alert("Vui lòng nhập Tên đăng nhập và Họ tên khách hàng.");

    const body = {
        username,
        password: "123456",
        fullName,
        phone: document.getElementById("cPhone").value.trim(),
        age: Number(document.getElementById("cAge").value || 22),
        gender: document.getElementById("cGender").value,
        interest: document.getElementById("cInterest").value,
        address: document.getElementById("cAddress").value.trim() || "TP. Hồ Chí Minh"
    };

    try {
        const res = await fetch(`${CRM_API}/customers`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Không thể thêm khách hàng.");

        alert(data.message || "Đã thêm khách hàng mới thành công!");
        closeCustomerModal();
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi thêm khách hàng: " + err.message);
    }
}

// KHÓA TÀI KHOẢN KHÁCH HÀNG
async function toggleLock(id) {
    try {
        const res = await fetch(`${CRM_API}/customers/${id}/toggle-status`, { method: "PUT" });
        const data = await res.json();
        if (data && data.message) alert(data.message);
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi đổi trạng thái khóa tài khoản: " + err.message);
    }
}

// XÓA KHÁCH HÀNG
async function deleteCustomer(id) {
    if (!confirm("Xác nhận xóa khách hàng này khỏi hệ thống?")) return;
    try {
        const res = await fetch(`${CRM_API}/customers/${id}`, { method: "DELETE" });
        const data = await res.json();
        alert(data.message || "Đã xóa khách hàng.");
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi khi xóa khách hàng: " + err.message);
    }
}

// =========================================================
// 2. TIẾP NHẬN PHẢN HỒI SẢN PHẨM & ĐÁNH GIÁ BÀI KHẢO SÁT CỦA KHÁCH HÀNG
// =========================================================
function formatSurveyResponseAnswersHtml(r) {
    let itemsHtml = "";
    if (r.answersJson) {
        try {
            const parsed = JSON.parse(r.answersJson);
            if (Array.isArray(parsed) && parsed.length > 0) {
                itemsHtml = parsed.map((ans, idx) => {
                    const ansText = Array.isArray(ans.answer) ? ans.answer.join(", ") : (ans.answer || "-");
                    const reqBadge = ans.requirement
                        ? `<span style="background:#FFF7ED; color:#EA580C; border:1px solid #FED7AA; font-size:10px; font-weight:700; padding:1px 6px; border-radius:4px; margin-right:4px;">${ans.requirement}</span>`
                        : "";
                    return `
                        <div style="margin-bottom:5px; font-size:12px; line-height:1.45; padding:4px 8px; background:#F8FAFC; border-left:2.5px solid #FF6A00; border-radius:4px;">
                            <div>${reqBadge}<b style="color:#0F172A;">Câu ${idx + 1} (${ans.question || "Câu hỏi"}):</b></div>
                            <div style="color:#1E40AF; font-weight:600; margin-top:2px;">&rarr; ${ansText}</div>
                        </div>
                    `;
                }).join("");
                return itemsHtml;
            }
        } catch (e) {
            console.warn("Lỗi parse answersJson:", e);
        }
    }

    // Fallback phân tích từ chuỗi customerOpinion
    const raw = r.customerOpinion || "";
    const bracketMatches = [...raw.matchAll(/\[([^\]:]+):\s*([^\]]+)\]/g)];
    if (bracketMatches.length > 0) {
        return bracketMatches.map((m, idx) => `
            <div style="margin-bottom:4px; font-size:12px; line-height:1.4; padding:3px 8px; background:#F8FAFC; border-left:2.5px solid #2563EB; border-radius:4px;">
                <b style="color:#0F172A;">${idx + 1}. ${m[1].trim()}:</b> <span style="color:#1E40AF; font-weight:600;">${m[2].trim()}</span>
            </div>
        `).join("");
    }

    return `<div style="font-size:12.5px; color:#0F172A;">"${raw || "Đã hoàn thành phiếu khảo sát"}"</div>`;
}

function extractCleanSurveyOpinionNotes(r) {
    const raw = r.customerOpinion || "";
    const gopyMatch = raw.match(/\[(?:Góp ý|Ý kiến|Đề xuất)[^\]:]*:\s*([^\]]+)\]/i);
    const priceMatch = raw.match(/\[Giá (?:sẵn sàng chi|kỳ vọng)[^\]:]*:\s*([^\]]+)\]/i);
    let note = gopyMatch ? gopyMatch[1].trim() : "";
    if (!note) {
        note = raw.replace(/\[[^\]]+\]/g, "").replace(/\|/g, "").trim();
    }
    return {
        note: note || "Khách hàng đã gửi đầy đủ đánh giá theo các câu hỏi khảo sát.",
        willingPrice: priceMatch ? priceMatch[1].trim() : ""
    };
}

async function loadSurveyResponses() {
    try {
        const res = await fetch(`${CRM_API}/survey-responses`);
        if (res.ok) {
            allSurveyResponsesCache = await res.json();
        }
    } catch (e) {
        console.warn("Không thể tải danh sách phản hồi khảo sát:", e);
    }

    // Cập nhật dropdown lọc theo chiến dịch khảo sát trong Tab 2
    const filterSel = document.getElementById("fbTabSurveyFilter");
    if (filterSel) {
        const curVal = filterSel.value;
        filterSel.innerHTML = `<option value="">Tất cả chiến dịch khảo sát (${allSurveyResponsesCache.length} đánh giá)</option>` +
            allSurveysCache.map(s => {
                const c = allSurveyResponsesCache.filter(r => r.surveyId === s.surveyId).length;
                return `<option value="${s.surveyId}">#${s.surveyId} - ${s.title} (${c} đánh giá)</option>`;
            }).join("");
        if (curVal) filterSel.value = curVal;
    }

    renderSurveyResponsesInFeedbackTab();
}

function renderSurveyResponsesInFeedbackTab() {
    const tbody = document.getElementById("surveyFeedbackList");
    if (!tbody) return;

    const filterSurveyId = Number(document.getElementById("fbTabSurveyFilter")?.value || 0);
    const filtered = filterSurveyId > 0
        ? allSurveyResponsesCache.filter(r => r.surveyId === filterSurveyId)
        : allSurveyResponsesCache;

    const pendingCount = filtered.filter(r => !r.adminReply || !r.adminReply.trim()).length;
    const badge = document.getElementById("crmSurveyRespCountBadge");
    if (badge) {
        badge.innerText = `${filtered.length} đánh giá khảo sát (${pendingCount} chờ phản hồi)`;
    }

    if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding:24px; color:var(--text-muted);">Chưa có đánh giá khảo sát nào từ khách hàng cho bộ lọc này.</td></tr>`;
        return;
    }

    tbody.innerHTML = filtered.map(r => {
        const hasReply = r.adminReply && r.adminReply.trim().length > 0;
        const dt = r.submittedAt ? new Date(r.submittedAt).toLocaleString("vi-VN") : "-";
        const answersHtml = formatSurveyResponseAnswersHtml(r);
        return `
            <tr>
                <td>
                    <div style="font-weight:700; color:#0F172A;">${r.customerName}</div>
                    <div style="font-size:11.5px; color:#64748B;">@${r.customerUsername || "khachhang"}</div>
                    <div style="font-size:11px; color:#94A3B8; margin-top:2px;">${dt}</div>
                </td>
                <td>
                    <b style="color:#0F172A; font-size:13px;">#${r.surveyId} - ${r.surveyTitle}</b>
                    <div style="color:#1D4ED8; font-weight:700; font-size:12px; margin-top:2px;">${r.targetProduct}</div>
                    <div style="color:#059669; font-weight:700; font-size:11.5px;">${Number(r.expectedPrice || 0).toLocaleString("vi-VN")} ₫</div>
                </td>
                <td>
                    <span class="star-rating-box" style="margin-bottom:5px; display:inline-flex;">
                        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span>${r.score}.0 / 5</span>
                    </span>
                    <div>
                        <span class="badge ${r.buyingIntent && (r.buyingIntent.includes('Rất muốn') || r.buyingIntent.includes('Đặt trước')) ? 'badge-active' : (r.buyingIntent && (r.buyingIntent.includes('Không') || r.buyingIntent.includes('Chưa có'))) ? 'badge-locked' : 'badge-info'}" style="font-size:11px;">
                            ${r.buyingIntent}
                        </span>
                    </div>
                </td>
                <td>${answersHtml}</td>
                <td>
                    ${hasReply
                        ? `<div class="review-reply-box" style="margin-top:0; background:#ECFDF5; border-left:3px solid #059669; padding:8px 10px; border-radius:6px; font-size:12px; color:#065F46;">
                               <div style="font-weight:800; font-size:10.5px; text-transform:uppercase; margin-bottom:2px;">✓ Đã phản hồi khách hàng:</div>
                               <div>${r.adminReply}</div>
                           </div>`
                        : `<span style="color:#D97706; font-size:12px; font-weight:600;">⏳ Đang chờ Quản lý tiếp nhận & phản hồi...</span>`}
                </td>
                <td>
                    <span class="badge ${hasReply ? 'badge-active' : 'badge-locked'}">
                        ${hasReply ? 'Đã tiếp nhận & Phản hồi' : 'Chờ tiếp nhận'}
                    </span>
                </td>
                <td style="text-align:center;">
                    <button class="btn" style="padding:6px 12px; font-size:12px;" onclick="openSurveyReplyModal(${r.responseId})">
                        ${hasReply ? 'Sửa phản hồi' : 'Tiếp nhận & Trả lời'}
                    </button>
                </td>
            </tr>
        `;
    }).join("");
}

async function loadFeedbacks() {
    try {
        const res = await fetch(`${CRM_API}/feedbacks`);
        if (res.ok) {
            allFeedbacksCache = await res.json();
        }
    } catch (e) {
        console.warn("Sử dụng dữ liệu phản hồi dự phòng:", e);
    }
    try {
        const fbTotal = allFeedbacksCache.length;
        const fbAnswered = allFeedbacksCache.filter(f => f.adminReply && f.adminReply.trim().length > 0).length;
        const svTotal = allSurveyResponsesCache.length;
        const svAnswered = allSurveyResponsesCache.filter(r => r.adminReply && r.adminReply.trim().length > 0).length;

        const total = fbTotal + svTotal;
        const answered = fbAnswered + svAnswered;
        const pending = total - answered;

        const allScores = [
            ...allFeedbacksCache.map(f => Number(f.rating || 5)),
            ...allSurveyResponsesCache.map(r => Number(r.score || 5))
        ];
        const avgScore = allScores.length > 0
            ? (allScores.reduce((sum, v) => sum + v, 0) / allScores.length).toFixed(1)
            : "5.0";

        if (document.getElementById("crmKpiTotal")) document.getElementById("crmKpiTotal").innerText = `${total} (${svTotal} KS · ${fbTotal} SP)`;
        if (document.getElementById("crmKpiAnswered")) document.getElementById("crmKpiAnswered").innerText = answered;
        if (document.getElementById("crmKpiPending")) document.getElementById("crmKpiPending").innerText = pending;
        if (document.getElementById("crmKpiAvg")) document.getElementById("crmKpiAvg").innerText = `${avgScore} / 5.0`;
        if (document.getElementById("crmTotalReviewsBadge")) document.getElementById("crmTotalReviewsBadge").innerText = `${fbTotal} phản hồi SP`;

        renderSurveyResponsesInFeedbackTab();

        // Biểu đồ 1: Sao
        const starCanvas = document.getElementById("crmRatingBarChart");
        if (starCanvas && typeof Chart !== "undefined") {
            const starCounts = [1, 2, 3, 4, 5].map(s => allFeedbacksCache.filter(f => f.rating === s).length);
            const ctx1 = starCanvas.getContext("2d");
            if (crmStarChart) crmStarChart.destroy();
            crmStarChart = new Chart(ctx1, {
                type: "bar",
                data: {
                    labels: ["1 Sao", "2 Sao", "3 Sao", "4 Sao", "5 Sao"],
                    datasets: [{
                        label: "Số lượng phản hồi",
                        data: starCounts,
                        backgroundColor: ["#dc2626", "#ea580c", "#f59e0b", "#2563eb", "#059669"],
                        borderRadius: 5,
                        barThickness: 28
                    }]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        }

        // Biểu đồ 2: Sản phẩm
        const prodCanvas = document.getElementById("crmProductReviewChart");
        if (prodCanvas && typeof Chart !== "undefined") {
            const prodCounts = {};
            allFeedbacksCache.forEach(f => {
                const p = f.productName || "Khác";
                prodCounts[p] = (prodCounts[p] || 0) + 1;
            });

            const ctx2 = prodCanvas.getContext("2d");
            if (crmProdChart) crmProdChart.destroy();
            crmProdChart = new Chart(ctx2, {
                type: "doughnut",
                data: {
                    labels: Object.keys(prodCounts),
                    datasets: [{
                        data: Object.values(prodCounts),
                        backgroundColor: ["#2563eb", "#059669", "#7c3aed", "#ea580c", "#0284c7", "#ec4899", "#f59e0b"]
                    }]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: "bottom" } }
                }
            });
        }

        // Bảng phản hồi sản phẩm
        document.getElementById("feedbackList").innerHTML = allFeedbacksCache.map(f => {
            const hasReply = f.adminReply && f.adminReply.trim().length > 0;
            return `
                <tr>
                    <td><b>${f.customerName}</b></td>
                    <td><b>${f.productName}</b></td>
                    <td>
                        <span class="star-rating-box">
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <span>${f.rating}.0 / 5</span>
                        </span>
                    </td>
                    <td>"${f.comment}"</td>
                    <td>
                        ${hasReply ? `<div class="review-reply-box" style="margin-top:0;">${f.adminReply}</div>` : `<span style="color:var(--text-muted); font-size:12px;">Đang chờ tiếp nhận...</span>`}
                    </td>
                    <td>
                        <span class="badge ${hasReply ? 'badge-active' : 'badge-locked'}">
                            ${hasReply ? 'Đã tiếp nhận & xử lý' : 'Chờ tiếp nhận'}
                        </span>
                    </td>
                    <td style="text-align:center;">
                        <button class="btn" style="padding:5px 10px; font-size:12px;" onclick="openReplyModal(${f.feedbackId})">
                            ${hasReply ? 'Sửa phản hồi' : 'Tiếp nhận & Trả lời'}
                        </button>
                    </td>
                </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadFeedbacks:", e);
    }
}

function openReplyModal(feedbackId) {
    const fb = allFeedbacksCache.find(x => x.feedbackId === feedbackId);
    if (!fb) return;
    replyTargetType = "feedback";
    selectedFeedbackId = fb.feedbackId;
    document.getElementById("replyModalMeta").innerText = `[Đánh giá Sản phẩm] Khách hàng: ${fb.customerName} | Sản phẩm: ${fb.productName} (${fb.rating}/5 sao)`;
    document.getElementById("replyModalComment").innerText = `"${fb.comment}"`;
    document.getElementById("replyModalText").value = fb.adminReply || "Cảm ơn quý khách đã gửi đánh giá sản phẩm! Bộ phận Quản lý CRM SGU Tech đã tiếp nhận và xử lý yêu cầu của bạn.";
    document.getElementById("replyModal").classList.add("show");
}

function openSurveyReplyModal(responseId) {
    let resp = allSurveyResponsesCache.find(x => x.responseId === responseId);
    if (!resp && window.currentSurveyStatResponses) {
        resp = window.currentSurveyStatResponses.find(x => x.responseId === responseId);
    }
    if (!resp) return;

    replyTargetType = "survey";
    selectedSurveyResponseId = resp.responseId;
    document.getElementById("replyModalMeta").innerText =
        `[Đánh giá Bài Khảo sát] Khách hàng: ${resp.customerName} (@${resp.customerUsername || "khachhang"}) | Chiến dịch: ${resp.surveyTitle || "Khảo sát"} (${resp.score}/5 ★ - ${resp.buyingIntent})`;

    let summaryText = resp.customerOpinion || "";
    if (resp.answersJson) {
        try {
            const arr = JSON.parse(resp.answersJson);
            if (Array.isArray(arr) && arr.length > 0) {
                summaryText = arr.map((a, i) => `Câu ${i + 1} (${a.requirement || a.question}): ${Array.isArray(a.answer) ? a.answer.join(", ") : a.answer}`).join(" | ");
            }
        } catch (e) {}
    }
    document.getElementById("replyModalComment").innerText = summaryText;
    document.getElementById("replyModalText").value = resp.adminReply ||
        `Cảm ơn bạn ${resp.customerName} đã tham gia khảo sát sản phẩm ${resp.targetProduct || "mới"}! Bộ phận Quản lý CRM đã tiếp nhận toàn bộ các yêu cầu của bạn và sẽ áp dụng ưu đãi đặc biệt khi mở bán.`;
    document.getElementById("replyModal").classList.add("show");
}

function closeReplyModal() {
    document.getElementById("replyModal").classList.remove("show");
}

async function submitReplyFeedback() {
    const reply = document.getElementById("replyModalText").value.trim();
    if (!reply) return alert("Vui lòng nhập nội dung phản hồi giải đáp gửi khách hàng.");

    try {
        if (replyTargetType === "survey") {
            const res = await fetch(`${CRM_API}/survey-responses/${selectedSurveyResponseId}/reply`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ adminReply: reply })
            });
            const data = await res.json();
            if (!res.ok) return alert(data.message || "Không thể gửi phản hồi khảo sát.");

            alert(data.message || "Đã tiếp nhận và gửi phản hồi đánh giá khảo sát cho khách hàng!");
            closeReplyModal();
            await Promise.all([
                loadSurveys(),
                loadSurveyResponses(),
                loadFeedbacks()
            ]);
            if (currentViewedSurveyId) {
                await viewSurveyStats(currentViewedSurveyId, false);
            }
            notifyDataChanged("surveys");
        } else {
            const res = await fetch(`${CRM_API}/feedbacks/${selectedFeedbackId}/reply`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ adminReply: reply })
            });
            const data = await res.json();
            if (!res.ok) return alert(data.message || "Không thể gửi phản hồi.");

            alert("Đã tiếp nhận và gửi phản hồi cho khách hàng!");
            closeReplyModal();
            await loadFeedbacks();
            notifyDataChanged("feedbacks");
        }
    } catch (err) {
        alert("Lỗi khi gửi phản hồi: " + err.message);
    }
}

// =========================================================
// 3. BÁO CÁO VỀ KHÁCH HÀNG, TỶ LỆ ĐỘ TUỔI, SỞ THÍCH
// =========================================================
async function loadDemographics() {
    let data = {
        totalCustomers: 15,
        ageStats: { under20: 3, from20To30: 8, over30: 4 },
        interestStats: [
            { interest: "Gaming", count: 5, percentage: 33.3 },
            { interest: "Văn phòng", count: 4, percentage: 26.7 },
            { interest: "Đồ họa", count: 3, percentage: 20.0 },
            { interest: "Lập trình", count: 3, percentage: 20.0 }
        ]
    };
    try {
        const res = await fetch(`${CRM_API}/reports/demographics`);
        if (res.ok) {
            data = await res.json();
        }
    } catch (e) {
        console.warn("Sử dụng dữ liệu nhân khẩu học dự phòng:", e);
    }
    try {
        const total = data.totalCustomers || 1;
        document.getElementById("totalCus").innerText = data.totalCustomers;

        const u20 = Math.round((data.ageStats.under20 / total) * 100);
        const f20_30 = Math.round((data.ageStats.from20To30 / total) * 100);
        const o30 = Math.round((data.ageStats.over30 / total) * 100);

        const youngRatio = Math.round(((data.ageStats.under20 + data.ageStats.from20To30) / total) * 100);
        if (document.getElementById("dominantAgeVal")) {
            document.getElementById("dominantAgeVal").innerText = `18 - 30 tuổi (${youngRatio}%)`;
        }
        if (document.getElementById("dominantInterestVal") && data.interestStats && data.interestStats.length > 0) {
            const sortedInt = [...data.interestStats].sort((a, b) => b.count - a.count);
            if (sortedInt.length >= 2) {
                const topTwoPct = (Number(sortedInt[0].percentage) + Number(sortedInt[1].percentage)).toFixed(1).replace(/\.0$/, "");
                document.getElementById("dominantInterestVal").innerText = `${sortedInt[0].interest} & ${sortedInt[1].interest} (${topTwoPct}%)`;
            } else {
                document.getElementById("dominantInterestVal").innerText = `${sortedInt[0].interest} (${sortedInt[0].percentage}%)`;
            }
        }

        // Biểu đồ 1: Tỷ lệ Độ tuổi
        const ageCanvas = document.getElementById("agePieChart");
        if (ageCanvas && typeof Chart !== "undefined") {
            const ctxAge = ageCanvas.getContext("2d");
            if (agePieChartInstance) agePieChartInstance.destroy();
            agePieChartInstance = new Chart(ctxAge, {
                type: "doughnut",
                data: {
                    labels: [`Dưới 20 tuổi (${u20}%)`, `Từ 20 - 30 tuổi (${f20_30}%)`, `Trên 30 tuổi (${o30}%)`],
                    datasets: [{
                        data: [data.ageStats.under20, data.ageStats.from20To30, data.ageStats.over30],
                        backgroundColor: ["#2563eb", "#059669", "#ea580c"]
                    }]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: "bottom" } }
                }
            });
        }

        // Biểu đồ 2: Tỷ lệ Sở thích
        const intCanvas = document.getElementById("interestBarChart");
        if (intCanvas && typeof Chart !== "undefined") {
            const ctxInt = intCanvas.getContext("2d");
            if (interestBarChartInstance) interestBarChartInstance.destroy();
            interestBarChartInstance = new Chart(ctxInt, {
                type: "bar",
                data: {
                    labels: data.interestStats.map(i => `${i.interest} (${i.percentage}%)`),
                    datasets: [{
                        label: "Số lượng khách hàng",
                        data: data.interestStats.map(i => i.count),
                        backgroundColor: ["#dc2626", "#2563eb", "#7c3aed", "#059669"],
                        borderRadius: 5,
                        barThickness: 32
                    }]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        }

        document.getElementById("ageReportBox").innerHTML = `
            <div style="margin-bottom:12px;">
                <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                    <span>Dưới 20 tuổi (Sinh viên / Gen Z):</span>
                    <b>${data.ageStats.under20} khách hàng (${u20}%)</b>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${u20}%; background:#2563eb;"></div></div>
            </div>

            <div style="margin-bottom:12px;">
                <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                    <span>Từ 20 - 30 tuổi (Thanh niên / Đi làm):</span>
                    <b>${data.ageStats.from20To30} khách hàng (${f20_30}%)</b>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${f20_30}%; background:#059669;"></div></div>
            </div>

            <div>
                <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                    <span>Trên 30 tuổi (Chuyên gia / Quản lý):</span>
                    <b>${data.ageStats.over30} khách hàng (${o30}%)</b>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${o30}%; background:#ea580c;"></div></div>
            </div>
        `;

        document.getElementById("interestReportBox").innerHTML = data.interestStats.map(i => {
            const colors = {
                "Gaming": "#dc2626",
                "Văn phòng": "#2563eb",
                "Đồ họa": "#7c3aed",
                "Lập trình": "#059669"
            };
            const c = colors[i.interest] || "#10b981";

            return `
                <div style="margin-bottom:12px;">
                    <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                        <span>Sở thích <b>${i.interest}</b>:</span>
                        <b>${i.count} khách hàng (${i.percentage}%)</b>
                    </div>
                    <div class="progress-bar"><div class="progress-fill" style="background:${c}; width:${i.percentage}%"></div></div>
                </div>
            `;
        }).join("");

        renderDemographicsCustomerTable();
    } catch (e) {
        console.error("Lỗi loadDemographics:", e);
    }
}

function renderDemographicsCustomerTable() {
    const tbody = document.getElementById("demographicsCustomerTable");
    if (!tbody) return;
    if (!allCustomersCache || allCustomersCache.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8" style="text-align:center; padding:16px;">Chưa có dữ liệu khách hàng.</td></tr>`;
        return;
    }

    tbody.innerHTML = allCustomersCache.map(c => {
        const age = c.profile?.age || 20;
        const gender = c.profile?.gender || "Nam";
        const interest = c.profile?.interest || "Khác";
        const addr = c.profile?.address || "TP. Hồ Chí Minh";
        let groupText = "Từ 20 - 30 tuổi";
        if (age < 20) groupText = "Dưới 20 tuổi";
        else if (age > 30) groupText = "Trên 30 tuổi";

        return `
            <tr>
                <td><b>#${c.accountId}</b></td>
                <td><b>${c.username}</b></td>
                <td>${c.fullName}</td>
                <td>${gender}</td>
                <td><b>${age} tuổi</b></td>
                <td><span class="badge badge-info">${groupText}</span></td>
                <td><span class="badge badge-active">${interest}</span></td>
                <td><small>${addr}</small></td>
            </tr>
        `;
    }).join("");
}

// =========================================================
// 4. TẠO BẢNG KHẢO SÁT ĐA CÂU HỎI & ĐA YÊU CẦU VÀ GỬI ĐẾN TK KHÁCH HÀNG
// =========================================================
function renderSurveyRequirementsBuilder() {
    const box = document.getElementById("surveyRequirementsBox");
    if (!box) return;

    box.innerHTML = builderRequirements.map((req, idx) => `
        <label style="display:inline-flex; align-items:center; gap:6px; padding:5px 10px; background:${req.checked ? '#FFFFFF' : '#F1F5F9'}; border:1.5px solid ${req.checked ? '#FF6A00' : '#CBD5E1'}; border-radius:6px; font-size:12px; font-weight:600; color:#0F172A; cursor:pointer; margin:0;">
            <input type="checkbox" ${req.checked ? 'checked' : ''} onchange="toggleBuilderRequirement(${idx}, this.checked)" style="width:auto; margin:0;">
            <span>${req.text}</span>
        </label>
    `).join("");
}

function toggleBuilderRequirement(idx, checked) {
    if (builderRequirements[idx]) {
        builderRequirements[idx].checked = checked;
        renderSurveyRequirementsBuilder();
    }
}

function addCustomSurveyRequirement() {
    const inp = document.getElementById("newSurveyReqInput");
    const val = (inp?.value || "").trim();
    if (!val) return alert("Vui lòng nhập nội dung yêu cầu khảo sát cần thêm!");
    builderRequirements.push({ text: val, checked: true });
    inp.value = "";
    renderSurveyRequirementsBuilder();
}

function syncBuilderQuestionsFromDom() {
    const cards = document.querySelectorAll(".builder-q-card");
    if (!cards || cards.length === 0) return;
    cards.forEach((card, idx) => {
        if (!builderQuestions[idx]) return;
        const reqEl = card.querySelector(".bq-req");
        const qEl = card.querySelector(".bq-question");
        const typeEl = card.querySelector(".bq-type");
        const optEl = card.querySelector(".bq-options");
        if (reqEl) builderQuestions[idx].requirement = reqEl.value.trim();
        if (qEl) builderQuestions[idx].question = qEl.value.trim();
        if (typeEl) builderQuestions[idx].type = typeEl.value;
        if (optEl) {
            builderQuestions[idx].options = optEl.value
                .split(",")
                .map(s => s.trim())
                .filter(Boolean);
        }
    });
}

function renderInlineSurveyQuestionsBuilder() {
    const container = document.getElementById("inlineQuestionsContainer");
    if (!container) return;

    const countEl = document.getElementById("builderQuestionCount");
    if (countEl) countEl.innerText = builderQuestions.length;

    container.innerHTML = builderQuestions.map((q, idx) => {
        const optsStr = Array.isArray(q.options) ? q.options.join(", ") : "";
        const isText = q.type === "text";
        const isRating = q.type === "rating";
        return `
            <div class="builder-q-card" style="background:#FFFFFF; border:1px solid #CBD5E1; border-left:4px solid #FF6A00; border-radius:8px; padding:12px 14px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; gap:8px;">
                    <div style="display:flex; align-items:center; gap:8px;">
                        <span style="background:#FF6A00; color:#FFFFFF; font-weight:800; font-size:11.5px; padding:2px 8px; border-radius:4px;">Câu hỏi #${idx + 1}</span>
                        <span style="font-size:12px; color:#64748B; font-weight:600;">Thiết lập yêu cầu & nội dung câu hỏi khảo sát</span>
                    </div>
                    <button type="button" class="btn btn-danger" onclick="removeInlineSurveyQuestion(${idx})" style="padding:3px 10px; font-size:11.5px;">
                        Xóa câu #${idx + 1}
                    </button>
                </div>

                <div class="grid-form" style="grid-template-columns: 1.1fr 2fr 1.1fr; gap:10px; margin-bottom:8px;">
                    <div>
                        <label style="font-size:11.5px;">Nhóm yêu cầu khảo sát *</label>
                        <input type="text" class="bq-req" value="${(q.requirement || "").replace(/"/g, '&quot;')}" placeholder="VD: Yêu cầu về mức giá / cấu hình...">
                    </div>
                    <div>
                        <label style="font-size:11.5px;">Nội dung câu hỏi khảo sát gửi khách hàng *</label>
                        <input type="text" class="bq-question" value="${(q.question || "").replace(/"/g, '&quot;')}" placeholder="Nhập câu hỏi cụ thể cho khách hàng...">
                    </div>
                    <div>
                        <label style="font-size:11.5px;">Loại câu hỏi & hình thức trả lời</label>
                        <select class="bq-type" onchange="onBuilderQuestionTypeChange(${idx}, this.value)">
                            <option value="rating" ${q.type === 'rating' ? 'selected' : ''}>Thang điểm đánh giá (1 - 5 mức độ)</option>
                            <option value="single" ${q.type === 'single' ? 'selected' : ''}>Trắc nghiệm 1 lựa chọn (Single Choice)</option>
                            <option value="multi" ${q.type === 'multi' ? 'selected' : ''}>Chọn nhiều yêu cầu / tiêu chí (Multi-Select)</option>
                            <option value="text" ${q.type === 'text' ? 'selected' : ''}>Tự luận / Đề xuất mức giá & Yêu cầu riêng</option>
                        </select>
                    </div>
                </div>

                <div style="display:${isText ? 'none' : 'block'};">
                    <label style="font-size:11.5px; color:#475569;">
                        ${isRating ? 'Các nhãn mức điểm 1 -> 5 (phân cách bằng dấu phẩy):' : 'Các phương án lựa chọn / yêu cầu chi tiết (phân cách bằng dấu phẩy):'}
                    </label>
                    <input type="text" class="bq-options" value="${optsStr.replace(/"/g, '&quot;')}" placeholder="Nhập các phương án trả lời, cách nhau bởi dấu phẩy (,)">
                </div>
            </div>
        `;
    }).join("");
}

function onBuilderQuestionTypeChange(idx, newType) {
    syncBuilderQuestionsFromDom();
    if (!builderQuestions[idx]) return;
    builderQuestions[idx].type = newType;
    if (newType === "rating" && (!builderQuestions[idx].options || builderQuestions[idx].options.length === 0)) {
        builderQuestions[idx].options = ["1 - Rất thờ ơ", "2 - Ít quan tâm", "3 - Bình thường", "4 - Khá quan tâm", "5 - Rất hào hứng"];
    } else if (newType === "single" && (!builderQuestions[idx].options || builderQuestions[idx].options.length === 0)) {
        builderQuestions[idx].options = ["Rất đồng ý / Phù hợp", "Bình thường / Cân nhắc", "Chưa phù hợp / Cần cải thiện"];
    } else if (newType === "multi" && (!builderQuestions[idx].options || builderQuestions[idx].options.length === 0)) {
        builderQuestions[idx].options = ["Yêu cầu hiệu năng cao", "Yêu cầu pin bền bỉ", "Yêu cầu thiết kế mỏng nhẹ", "Yêu cầu giá ưu đãi & quà tặng"];
    }
    renderInlineSurveyQuestionsBuilder();
}

function addInlineSurveyQuestion() {
    syncBuilderQuestionsFromDom();
    const nextNum = builderQuestions.length + 1;
    builderQuestions.push({
        id: nextNum,
        requirement: `Yêu cầu khảo sát bổ sung #${nextNum}`,
        question: `Câu hỏi khảo sát #${nextNum}: Bạn có yêu cầu hoặc đánh giá gì về tiêu chí này?`,
        type: "multi",
        required: true,
        options: ["Đáp ứng tốt nhu cầu công việc", "Cần nâng cấp thêm cấu hình", "Mức giá cần ưu đãi hơn", "Cần tặng kèm gói bảo hành mở rộng"]
    });
    renderInlineSurveyQuestionsBuilder();
}

function removeInlineSurveyQuestion(idx) {
    syncBuilderQuestionsFromDom();
    if (builderQuestions.length <= 1) {
        return alert("Bài khảo sát cần có ít nhất 1 câu hỏi!");
    }
    builderQuestions.splice(idx, 1);
    builderQuestions.forEach((q, i) => q.id = i + 1);
    renderInlineSurveyQuestionsBuilder();
}

function resetDefaultInlineSurveyQuestions() {
    builderRequirements = JSON.parse(JSON.stringify(DEFAULT_SURVEY_REQUIREMENTS));
    builderQuestions = getDefaultSurveyQuestionsTemplate();
    renderSurveyRequirementsBuilder();
    renderInlineSurveyQuestionsBuilder();
}

function collectBuilderPayload() {
    syncBuilderQuestionsFromDom();
    const selectedReqs = builderRequirements.filter(r => r.checked).map(r => r.text);
    const cleanQuestions = builderQuestions
        .filter(q => q.question && q.question.trim().length > 0)
        .map((q, idx) => ({
            id: idx + 1,
            requirement: q.requirement || `Yêu cầu khảo sát #${idx + 1}`,
            question: q.question.trim(),
            type: q.type || "single",
            required: q.type !== "text",
            options: Array.isArray(q.options) && q.options.length > 0
                ? q.options
                : (q.type === "rating"
                    ? ["1 - Rất thờ ơ", "2 - Ít quan tâm", "3 - Bình thường", "4 - Khá quan tâm", "5 - Rất hào hứng"]
                    : [])
        }));

    return {
        requirementsJson: JSON.stringify(selectedReqs.length > 0 ? selectedReqs : ["Yêu cầu khảo sát tổng thể sản phẩm mới"]),
        questionsJson: JSON.stringify(cleanQuestions),
        questionCount: cleanQuestions.length,
        reqCount: selectedReqs.length
    };
}

function renderSurveyRecipientCheckboxes() {
    const box = document.getElementById("surveyRecipientList");
    if (!box) return;
    const activeCustomers = allCustomersCache.filter(c => c.isActive);
    if (activeCustomers.length === 0) {
        box.innerHTML = `<span style="font-size:12px; color:var(--text-muted);">Chưa có tài khoản khách hàng hoạt động.</span>`;
        return;
    }

    box.innerHTML = activeCustomers.map(c => `
        <label style="display:inline-flex; align-items:center; gap:4px; padding:3px 8px; background:#ffffff; border:1px solid #cbd5e1; border-radius:4px; font-size:11.5px; font-weight:600; cursor:pointer; margin:0;">
            <input type="checkbox" class="cus-recipient-chk" value="${c.accountId}" checked onchange="updateSurveyRecipientBadge()" style="width:auto; margin:0;">
            <span>${c.username} (${c.fullName})</span>
        </label>
    `).join("");
    updateSurveyRecipientBadge();
}

function toggleAllSurveyRecipients(checked) {
    document.querySelectorAll(".cus-recipient-chk").forEach(chk => {
        chk.checked = checked;
    });
    updateSurveyRecipientBadge();
}

function updateSurveyRecipientBadge() {
    const chks = document.querySelectorAll(".cus-recipient-chk:checked");
    const badge = document.getElementById("surveyRecipientBadge");
    if (badge) {
        badge.innerText = `Sẽ gửi đến ${chks.length} tài khoản khách hàng`;
    }
}

async function submitInlineSurvey() {
    const title = document.getElementById("inlineSvTitle").value.trim();
    const targetProduct = document.getElementById("inlineSvProduct").value.trim();
    const expectedPrice = Number(document.getElementById("inlineSvPrice").value || 0);
    const description = document.getElementById("inlineSvDesc").value.trim();
    const durationVal = document.getElementById("inlineSvDuration").value;
    const selectedAccounts = document.querySelectorAll(".cus-recipient-chk:checked");

    if (!title || !targetProduct) {
        return alert("Vui lòng nhập đầy đủ Tiêu đề bảng khảo sát và Tên sản phẩm khảo sát!");
    }
    if (selectedAccounts.length === 0) {
        return alert("Vui lòng chọn ít nhất 1 tài khoản khách hàng để gửi khảo sát!");
    }

    const builderData = collectBuilderPayload();
    if (builderData.questionCount === 0) {
        return alert("Vui lòng thiết lập ít nhất 1 câu hỏi khảo sát!");
    }

    const body = {
        title,
        targetProduct,
        expectedPrice,
        description: description || `Chiến dịch khảo sát gồm ${builderData.reqCount} yêu cầu trọng tâm và ${builderData.questionCount} câu hỏi chuyên sâu.`,
        durationType: durationVal === "NoLimit" ? "NoLimit" : "Days",
        durationDays: durationVal === "NoLimit" ? null : Number(durationVal),
        expiresAt: null,
        requirementsJson: builderData.requirementsJson,
        questionsJson: builderData.questionsJson
    };

    try {
        const res = await fetch(`${CRM_API}/surveys`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Không thể tạo chiến dịch khảo sát.");

        alert(`Đã phát hành chiến dịch khảo sát "${title}" (gồm ${builderData.reqCount} yêu cầu & ${builderData.questionCount} câu hỏi) đến ${selectedAccounts.length} tài khoản khách hàng thành công!`);

        document.getElementById("inlineSvTitle").value = "";
        document.getElementById("inlineSvProduct").value = "";
        document.getElementById("inlineSvPrice").value = "";
        document.getElementById("inlineSvDesc").value = "";

        if (data && data.surveyId) {
            currentViewedSurveyId = data.surveyId;
        }
        await Promise.all([loadSurveys(), loadSurveyResponses()]);
        if (currentViewedSurveyId) {
            await viewSurveyStats(currentViewedSurveyId, true);
        }
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi tạo khảo sát: " + err.message);
    }
}

async function loadSurveys() {
    try {
        const res = await fetch(`${CRM_API}/surveys`);
        if (res.ok) {
            allSurveysCache = await res.json();
        }
    } catch (e) {
        console.warn("Sử dụng dữ liệu khảo sát dự phòng:", e);
    }
    try {
        // Populate dropdown in Tab 5 (Thống kê kết quả khảo sát)
        const statSelect = document.getElementById("statSurveySelect");
        if (statSelect) {
            const prevVal = currentViewedSurveyId || statSelect.value;
            statSelect.innerHTML = allSurveysCache.map(s =>
                `<option value="${s.surveyId}">#${s.surveyId} - ${s.title} (${s.targetProduct}) — ${s.totalResponses} đánh giá</option>`
            ).join("");
            if (prevVal && allSurveysCache.some(x => String(x.surveyId) === String(prevVal))) {
                statSelect.value = String(prevVal);
            }
        }

        const activeCustomerCount = allCustomersCache.filter(c => c.isActive).length || 13;

        document.getElementById("surveyList").innerHTML = allSurveysCache.map(s => {
            let expireText = `<span class="badge badge-info">Không thời hạn</span>`;
            if (s.expiresAt) {
                const d = new Date(s.expiresAt).toLocaleDateString("vi-VN");
                expireText = s.isExpired
                    ? `<span class="badge badge-locked">Hết hạn (${d})</span>`
                    : `<span class="badge badge-info">Đến ${d}</span>`;
            }

            let statusBadge = "";
            if (!s.isActive) {
                statusBadge = `<span class="badge badge-locked">Đã khóa</span>`;
            } else if (s.isExpired) {
                statusBadge = `<span class="badge badge-locked">Đã kết thúc</span>`;
            } else {
                statusBadge = `<span class="badge badge-active">Đang mở</span>`;
            }

            let qCount = 6;
            let reqCount = 4;
            try {
                if (s.questionsJson) {
                    const qArr = JSON.parse(s.questionsJson);
                    if (Array.isArray(qArr)) qCount = qArr.length;
                }
                if (s.requirementsJson) {
                    const rArr = JSON.parse(s.requirementsJson);
                    if (Array.isArray(rArr)) reqCount = rArr.length;
                }
            } catch (e) {}

            const pendingResp = s.pendingResponses ?? 0;

            return `
            <tr>
                <td>
                    <b>#${s.surveyId} - ${s.title}</b>
                    <div style="color:var(--text-muted); font-size:11.5px; margin-top:2px;">${s.description || ""}</div>
                    <div style="margin-top:5px; display:flex; gap:6px; flex-wrap:wrap;">
                        <span class="badge-tag" style="background:#FFF7ED; color:#EA580C; border:1px solid #FED7AA; font-size:10.5px;">📋 ${reqCount} yêu cầu khảo sát</span>
                        <span class="badge-tag" style="background:#EFF6FF; color:#1D4ED8; border:1px solid #BFDBFE; font-size:10.5px;">❓ ${qCount} câu hỏi chi tiết</span>
                    </div>
                </td>
                <td><b style="color:#1d4ed8;">${s.targetProduct}</b></td>
                <td><b>${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫</b></td>
                <td><span class="badge badge-active">Đã gửi đến ${s.totalCustomerAccounts || activeCustomerCount} TK khách hàng</span></td>
                <td>${expireText}</td>
                <td>${statusBadge}</td>
                <td>
                    <div><b style="font-size:14px; color:var(--text-primary);">${s.totalResponses}</b> lượt đánh giá</div>
                    ${pendingResp > 0
                        ? `<span style="font-size:11px; color:#D97706; font-weight:700;">(${pendingResp} chờ phản hồi)</span>`
                        : (s.totalResponses > 0 ? `<span style="font-size:11px; color:#059669; font-weight:700;">(Đã phản hồi đủ)</span>` : '')}
                </td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn" style="padding:4px 9px; font-size:12px;" onclick="openSurveyStatsTab(${s.surveyId})">Xem & Phản hồi (${s.totalResponses})</button>
                        <button class="btn btn-warning" style="padding:4px 9px; font-size:12px;" onclick="toggleSurveyLock(${s.surveyId})">${s.isActive ? 'Khóa' : 'Mở'}</button>
                        <button class="btn btn-danger" style="padding:4px 9px; font-size:12px;" onclick="deleteSurvey(${s.surveyId})">Xóa</button>
                    </div>
                </td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadSurveys:", e);
    }
}

function openCreateSurveyModal() {
    const titleInp = document.getElementById("inlineSvTitle");
    if (titleInp) {
        titleInp.scrollIntoView({ behavior: "smooth", block: "center" });
        titleInp.focus();
        return;
    }
    document.getElementById("svTitle").value = "";
    document.getElementById("svProduct").value = "";
    document.getElementById("svPrice").value = "";
    document.getElementById("svDesc").value = "";
    document.getElementById("svDurationType").value = "NoLimit";
    onDurationTypeChange();
    document.getElementById("surveyModal").classList.add("show");
}

function closeCreateSurveyModal() {
    document.getElementById("surveyModal").classList.remove("show");
}

function onDurationTypeChange() {
    const type = document.getElementById("svDurationType").value;
    document.getElementById("svDaysBox").style.display = type === "Days" ? "block" : "none";
    document.getElementById("svDateBox").style.display = type === "Date" ? "block" : "none";
}

async function submitCreateSurveyModal() {
    const title = document.getElementById("svTitle").value.trim();
    const targetProduct = document.getElementById("svProduct").value.trim();
    const expectedPrice = Number(document.getElementById("svPrice").value || 0);
    const description = document.getElementById("svDesc").value.trim();
    const durationType = document.getElementById("svDurationType").value;
    const durationDays = Number(document.getElementById("svDurationDays").value || 7);
    const expireDateVal = document.getElementById("svExpireDate").value;

    if (!title || !targetProduct) {
        return alert("Vui lòng nhập đầy đủ Tiêu đề khảo sát và Tên sản phẩm.");
    }
    if (durationType === "Date" && !expireDateVal) {
        return alert("Vui lòng chọn ngày kết thúc khảo sát.");
    }

    const builderData = collectBuilderPayload();

    const body = {
        title,
        targetProduct,
        expectedPrice,
        description,
        durationType,
        durationDays: durationType === "Days" ? durationDays : null,
        expiresAt: durationType === "Date" ? expireDateVal : null,
        requirementsJson: builderData.requirementsJson,
        questionsJson: builderData.questionsJson
    };

    try {
        const res = await fetch(`${CRM_API}/surveys`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();

        alert(data.message || "Đã tạo bảng khảo sát và gửi đến tài khoản khách hàng thành công!");
        closeCreateSurveyModal();
        if (data && data.surveyId) {
            currentViewedSurveyId = data.surveyId;
        }
        await Promise.all([loadSurveys(), loadSurveyResponses()]);
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi tạo khảo sát: " + err.message);
    }
}

async function toggleSurveyLock(id) {
    try {
        const res = await fetch(`${CRM_API}/surveys/${id}/toggle-lock`, { method: "PUT" });
        const data = await res.json();
        alert(data.message);
        await loadSurveys();
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi đổi trạng thái khảo sát: " + err.message);
    }
}

async function deleteSurvey(id) {
    if (!confirm("Xác nhận xóa bảng khảo sát này và toàn bộ dữ liệu phản hồi liên quan?")) return;
    try {
        const res = await fetch(`${CRM_API}/surveys/${id}`, { method: "DELETE" });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Không thể xóa khảo sát.");

        await Promise.all([loadSurveys(), loadSurveyResponses()]);
        if (allSurveysCache.length > 0) {
            await viewSurveyStats(allSurveysCache[0].surveyId, true);
        }
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi khi xóa: " + err.message);
    }
}

// =========================================================
// 5. THỐNG KÊ KẾT QUẢ KHẢO SÁT & TIẾP NHẬN PHẢN HỒI ĐÁNH GIÁ
// =========================================================
function openSurveyStatsTab(surveyId) {
    const navBtn = document.getElementById("navTabSurveyStats");
    currentViewedSurveyId = surveyId;
    switchTab("tabSurveyStats", navBtn);
    viewSurveyStats(surveyId, true);
}

async function viewSurveyStats(id, syncDropdown = true) {
    if (!id) return;
    currentViewedSurveyId = id;
    if (syncDropdown && document.getElementById("statSurveySelect")) {
        document.getElementById("statSurveySelect").value = String(id);
    }

    let s = null;
    try {
        const res = await fetch(`${CRM_API}/surveys/${id}/statistics`);
        if (res.ok) {
            s = await res.json();
        }
    } catch (e) {
        console.warn("Sử dụng thống kê khảo sát dự phòng:", e);
    }

    if (!s) return;

    try {
        window.currentSurveyStatResponses = s.detailResponses || [];
        const total = s.totalResponses || 0;
        const wantCount = s.intentStats?.wantToBuy || 0;
        const considerCount = s.intentStats?.considering || 0;
        const notBuyCount = s.intentStats?.notBuying || 0;
        const wantPct = total > 0 ? Math.round((wantCount / total) * 100) : 0;

        if (document.getElementById("statSurveyProductBadge")) {
            document.getElementById("statSurveyProductBadge").innerText = `${s.targetProduct} (${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫)`;
        }
        if (document.getElementById("statKpiTotalResp")) {
            document.getElementById("statKpiTotalResp").innerText = `${total} đánh giá`;
        }
        if (document.getElementById("statKpiAvgScore")) {
            document.getElementById("statKpiAvgScore").innerText = `${s.averageScore} / 5.0 ★`;
        }
        if (document.getElementById("statKpiWantToBuy")) {
            document.getElementById("statKpiWantToBuy").innerText = `${wantCount} KH (${wantPct}%)`;
        }
        if (document.getElementById("statKpiOtherIntent")) {
            document.getElementById("statKpiOtherIntent").innerText = `${considerCount} / ${notBuyCount}`;
        }

        // Biểu đồ 1: Ý định mua
        const intentCanvas = document.getElementById("surveyIntentChart");
        if (intentCanvas && typeof Chart !== "undefined") {
            const ctxIntent = intentCanvas.getContext("2d");
            if (surveyIntentChartInstance) surveyIntentChartInstance.destroy();
            surveyIntentChartInstance = new Chart(ctxIntent, {
                type: "doughnut",
                data: {
                    labels: [`Rất muốn mua (${wantCount})`, `Đang cân nhắc (${considerCount})`, `Không mua (${notBuyCount})`],
                    datasets: [{
                        data: total > 0 ? [wantCount, considerCount, notBuyCount] : [1, 0, 0],
                        backgroundColor: total > 0 ? ["#059669", "#2563eb", "#dc2626"] : ["#cbd5e1"]
                    }]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: "bottom" } }
                }
            });
        }

        // Biểu đồ 2: Điểm khảo sát 1 - 5
        const scoreCanvas = document.getElementById("surveyScoreChart");
        if (scoreCanvas && typeof Chart !== "undefined") {
            const dist = s.scoreDistribution || { score1: 0, score2: 0, score3: 0, score4: 0, score5: 0 };
            const ctxScore = scoreCanvas.getContext("2d");
            if (surveyScoreChartInstance) surveyScoreChartInstance.destroy();
            surveyScoreChartInstance = new Chart(ctxScore, {
                type: "bar",
                data: {
                    labels: ["1 Điểm", "2 Điểm", "3 Điểm", "4 Điểm", "5 Điểm"],
                    datasets: [{
                        label: "Số khách hàng",
                        data: [dist.score1 || 0, dist.score2 || 0, dist.score3 || 0, dist.score4 || 0, dist.score5 || 0],
                        backgroundColor: ["#dc2626", "#ea580c", "#f59e0b", "#2563eb", "#059669"],
                        borderRadius: 5,
                        barThickness: 28
                    }]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        }

        document.getElementById("statTitle").innerText = `Bảng Thống kê & Tiếp nhận Đánh giá Khảo sát: #${s.surveyId} - ${s.title} (${s.targetProduct})`;
        document.getElementById("statSummary").innerText =
            `• Tổng số khách hàng đã đánh giá: ${total} khách hàng (Đã phản hồi: ${s.answeredCount || 0} · Chờ phản hồi: ${s.pendingReplyCount || 0})  |  • Điểm quan tâm TB: ${s.averageScore} / 5.0 ★\n` +
            `• Cơ cấu ý định mua: Rất muốn mua (${wantCount})  ·  Đang cân nhắc (${considerCount})  ·  Không mua (${notBuyCount})`;

        const overviewEl = document.getElementById("statQuestionsOverview");
        if (overviewEl) {
            let reqList = [];
            let qList = [];
            try { if (s.requirementsJson) reqList = JSON.parse(s.requirementsJson); } catch (e) {}
            try { if (s.questionsJson) qList = JSON.parse(s.questionsJson); } catch (e) {}

            overviewEl.innerHTML = `
                <div style="margin-bottom:6px;">
                    <b style="color:#9A3412;">Các Yêu cầu Khảo sát (${reqList.length}):</b>
                    ${reqList.map(r => `<span class="badge-tag" style="background:#FFFFFF; color:#EA580C; border:1px solid #FED7AA; font-size:11px; margin-left:4px;">✓ ${r}</span>`).join("")}
                </div>
                <div>
                    <b style="color:#0F172A;">Danh sách Câu hỏi trong Bài Khảo sát (${qList.length} câu):</b>
                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap:6px; margin-top:6px;">
                        ${qList.map((q, idx) => `
                            <div style="background:#FFFFFF; border:1px solid #E2E8F0; padding:6px 10px; border-radius:6px; font-size:11.5px;">
                                <b style="color:#EA580C;">Câu ${idx + 1} [${q.requirement || q.type}]:</b> ${q.question}
                            </div>
                        `).join("")}
                    </div>
                </div>
            `;
        }

        if (!s.detailResponses || s.detailResponses.length === 0) {
            document.getElementById("statResponses").innerHTML = `<tr><td colspan="7" style="text-align:center; padding:28px; color:var(--text-muted); font-size:13.5px;">Chưa có khách hàng nào gửi đánh giá cho chiến dịch khảo sát này.</td></tr>`;
        } else {
            document.getElementById("statResponses").innerHTML = s.detailResponses.map(r => {
                const dt = r.submittedAt ? new Date(r.submittedAt).toLocaleString("vi-VN") : "-";
                const hasReply = r.adminReply && r.adminReply.trim().length > 0;
                const answersHtml = formatSurveyResponseAnswersHtml(r);
                const extra = extractCleanSurveyOpinionNotes(r);

                return `
                    <tr>
                        <td>
                            <div style="font-weight:700; color:#0F172A; font-size:13.5px;">${r.customerName}</div>
                            <div style="font-size:12px; color:#64748B;">@${r.customerUsername || "khachhang"}</div>
                            <div style="font-size:11px; color:#94A3B8; margin-top:2px;">${dt}</div>
                        </td>
                        <td>
                            <span class="star-rating-box" style="margin-bottom:5px; display:inline-flex;">
                                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                <span>${r.score}.0 / 5</span>
                            </span>
                            <div>
                                <span class="badge ${r.buyingIntent && (r.buyingIntent.includes('Đặt trước') || r.buyingIntent.includes('Rất muốn')) ? 'badge-active' : (r.buyingIntent && (r.buyingIntent.includes('Chưa có') || r.buyingIntent.includes('Không'))) ? 'badge-locked' : 'badge-info'}" style="font-size:11px;">
                                    ${r.buyingIntent}
                                </span>
                            </div>
                        </td>
                        <td>${answersHtml}</td>
                        <td>
                            <div style="font-size:12.5px; color:#0F172A; line-height:1.45;">"${extra.note}"</div>
                            ${extra.willingPrice ? `<div style="font-size:11.5px; color:#EA580C; font-weight:700; margin-top:4px;">💰 Giá sẵn sàng chi: ${extra.willingPrice}</div>` : ''}
                        </td>
                        <td>
                            ${hasReply
                                ? `<div style="background:#ECFDF5; border-left:3px solid #059669; padding:8px 10px; border-radius:6px; font-size:12px; color:#065F46; line-height:1.45;">
                                       <div style="font-weight:800; font-size:10.5px; text-transform:uppercase; margin-bottom:2px;">✓ Quản lý CRM đã phản hồi:</div>
                                       <div>${r.adminReply}</div>
                                   </div>`
                                : `<span style="color:#D97706; font-size:12px; font-weight:600;">⏳ Đang chờ Quản lý tiếp nhận...</span>`}
                        </td>
                        <td>
                            <span class="badge ${hasReply ? 'badge-active' : 'badge-locked'}">
                                ${hasReply ? 'Đã tiếp nhận & Phản hồi' : 'Chờ tiếp nhận'}
                            </span>
                        </td>
                        <td style="text-align:center;">
                            <button class="btn" style="padding:6px 12px; font-size:12px;" onclick="openSurveyReplyModal(${r.responseId})">
                                ${hasReply ? 'Sửa phản hồi' : 'Tiếp nhận & Trả lời'}
                            </button>
                        </td>
                    </tr>
                `;
            }).join("");
        }
    } catch (e) {
        console.error("Lỗi viewSurveyStats:", e);
    }
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}
