const CRM_API = "http://localhost:5000/api/admin/crm";
let currentViewedSurveyId = null;
let crmStarChart = null;
let crmProdChart = null;
let allFeedbacksCache = [];
let selectedFeedbackId = null;

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
    const user = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!user || (user.roleName !== "Manager" && user.roleName !== "Admin")) {
        return window.location.href = "login.html";
    }
    document.getElementById("managerName").innerText = "Quản lý: " + user.fullName;
    await refreshCrmDataSilently();
    setInterval(refreshCrmDataSilently, 4000);
};

async function refreshCrmDataSilently() {
    await Promise.all([
        loadCustomers(),
        loadFeedbacks(),
        loadDemographics(),
        loadSurveys()
    ]);
    if (currentViewedSurveyId) {
        await viewSurveyStats(currentViewedSurveyId);
    }
}

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));
    document.getElementById(id).style.display = "block";
    btn.classList.add("active");
}

function onDurationTypeChange() {
    const type = document.getElementById("svDurationType").value;
    document.getElementById("svDaysBox").style.display = type === "Days" ? "block" : "none";
    document.getElementById("svDateBox").style.display = type === "Date" ? "block" : "none";
}

async function loadCustomers() {
    const list = await (await fetch(`${CRM_API}/customers`)).json();
    document.getElementById("customerList").innerHTML = list.map(c => `
        <tr>
            <td><b>${c.username}</b></td>
            <td>${c.fullName}</td>
            <td>${c.phone || "-"}</td>
            <td>${c.profile?.age || "-"}</td>
            <td>${c.profile?.interest || "-"}</td>
            <td><span class="badge ${c.isActive ? 'badge-active' : 'badge-locked'}">${c.isActive ? 'Hoạt động' : 'Đã khóa'}</span></td>
            <td style="display:flex; gap:6px;">
                <button class="btn btn-warning" onclick="toggleLock(${c.accountId})">${c.isActive ? 'Khóa TK' : 'Mở khóa'}</button>
                <button class="btn btn-danger" onclick="deleteCustomer(${c.accountId})">Xóa</button>
            </td>
        </tr>
    `).join("");
}

async function addCustomer() {
    const username = document.getElementById("cUser").value.trim();
    const fullName = document.getElementById("cName").value.trim();
    if (!username || !fullName) return alert("Vui lòng nhập Tên đăng nhập và Họ tên khách hàng.");

    const body = {
        username,
        password: "123456",
        fullName,
        phone: document.getElementById("cPhone").value.trim(),
        age: Number(document.getElementById("cAge").value || 22),
        interest: document.getElementById("cInterest").value
    };
    const res = await fetch(`${CRM_API}/customers`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    const data = await res.json();
    alert(data.message);
    document.getElementById("cUser").value = "";
    document.getElementById("cName").value = "";
    document.getElementById("cPhone").value = "";
    document.getElementById("cAge").value = "";
    await refreshCrmDataSilently();
    notifyDataChanged("customers");
}

async function toggleLock(id) {
    await fetch(`${CRM_API}/customers/${id}/toggle-status`, { method: "PUT" });
    await refreshCrmDataSilently();
    notifyDataChanged("customers");
}

async function deleteCustomer(id) {
    if (!confirm("Xác nhận xóa hồ sơ khách hàng này?")) return;
    await fetch(`${CRM_API}/customers/${id}`, { method: "DELETE" });
    await refreshCrmDataSilently();
    notifyDataChanged("customers");
}

async function loadFeedbacks() {
    allFeedbacksCache = await (await fetch(`${CRM_API}/feedbacks`)).json();
    document.getElementById("crmTotalReviewsBadge").innerText = `${allFeedbacksCache.length} phản hồi`;

    const starCounts = [1, 2, 3, 4, 5].map(s => allFeedbacksCache.filter(f => f.rating === s).length);
    const ctx1 = document.getElementById("crmRatingBarChart").getContext("2d");
    if (crmStarChart) crmStarChart.destroy();
    crmStarChart = new Chart(ctx1, {
        type: "bar",
        data: {
            labels: ["1 Sao", "2 Sao", "3 Sao", "4 Sao", "5 Sao"],
            datasets: [{
                label: "Số lượng",
                data: starCounts,
                backgroundColor: ["#b91c1c", "#d97706", "#eab308", "#1e3a8a", "#65a30d"],
                borderRadius: 4,
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

    const prodCounts = {};
    allFeedbacksCache.forEach(f => {
        const p = f.productName || "Khác";
        prodCounts[p] = (prodCounts[p] || 0) + 1;
    });
    const ctx2 = document.getElementById("crmProductReviewChart").getContext("2d");
    if (crmProdChart) crmProdChart.destroy();
    crmProdChart = new Chart(ctx2, {
        type: "doughnut",
        data: {
            labels: Object.keys(prodCounts),
            datasets: [{
                data: Object.values(prodCounts),
                backgroundColor: ["#1e3a8a", "#65a30d", "#0284c7", "#d97706", "#4f46e5"]
            }]
        },
        options: {
            animation: false,
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: "bottom" } }
        }
    });

    document.getElementById("feedbackList").innerHTML = allFeedbacksCache.map(f => `
        <tr>
            <td><b>${f.customerName}</b></td>
            <td>${f.productName}</td>
            <td><b>${f.rating} / 5</b></td>
            <td>${f.comment}</td>
            <td>${f.adminReply || "<span style='color:#6b7280;'>Chưa phản hồi</span>"}</td>
            <td><span class="badge ${f.status.includes('Đã') ? 'badge-active' : 'badge-locked'}">${f.status}</span></td>
            <td><button class="btn" onclick="openReplyModal(${f.feedbackId})">Phản hồi</button></td>
        </tr>
    `).join("");
}

function openReplyModal(feedbackId) {
    const fb = allFeedbacksCache.find(x => x.feedbackId === feedbackId);
    if (!fb) return;
    selectedFeedbackId = fb.feedbackId;
    document.getElementById("replyModalMeta").innerText = `Khách hàng: ${fb.customerName} | Sản phẩm: ${fb.productName} (${fb.rating}/5 sao)`;
    document.getElementById("replyModalComment").innerText = `"${fb.comment}"`;
    document.getElementById("replyModalText").value = fb.adminReply || "";
    document.getElementById("replyModal").classList.add("show");
}

function closeReplyModal() {
    document.getElementById("replyModal").classList.remove("show");
}

async function submitReplyFeedback() {
    const reply = document.getElementById("replyModalText").value.trim();
    if (!reply) return alert("Vui lòng nhập nội dung phản hồi.");

    await fetch(`${CRM_API}/feedbacks/${selectedFeedbackId}/reply`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ adminReply: reply })
    });
    closeReplyModal();
    await loadFeedbacks();
    notifyDataChanged("feedbacks");
}

async function loadDemographics() {
    const data = await (await fetch(`${CRM_API}/reports/demographics`)).json();
    const total = data.totalCustomers || 1;
    document.getElementById("totalCus").innerText = data.totalCustomers;

    const u20 = Math.round((data.ageStats.under20 / total) * 100);
    const f20_30 = Math.round((data.ageStats.from20To30 / total) * 100);
    const o30 = Math.round((data.ageStats.over30 / total) * 100);

    document.getElementById("ageReportBox").innerHTML = `
        <div>Dưới 20 tuổi: <b>${data.ageStats.under20}</b> khách hàng (${u20}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="width:${u20}%"></div></div>
        <div>Từ 20 - 30 tuổi: <b>${data.ageStats.from20To30}</b> khách hàng (${f20_30}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="width:${f20_30}%"></div></div>
        <div>Trên 30 tuổi: <b>${data.ageStats.over30}</b> khách hàng (${o30}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="width:${o30}%"></div></div>
    `;

    document.getElementById("interestReportBox").innerHTML = data.interestStats.map(i => `
        <div>Nhóm <b>${i.interest}</b>: ${i.count} khách hàng (${i.percentage}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="background:var(--success); width:${i.percentage}%"></div></div>
    `).join("");
}

async function loadSurveys() {
    const list = await (await fetch(`${CRM_API}/surveys`)).json();
    document.getElementById("surveyList").innerHTML = list.map(s => {
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
            statusBadge = `<span class="badge badge-locked">Hết hạn</span>`;
        } else {
            statusBadge = `<span class="badge badge-active">Đang mở</span>`;
        }

        return `
        <tr>
            <td><b>${s.title}</b><br><small style="color:var(--text-muted);">${s.description || ""}</small></td>
            <td>${s.targetProduct}</td>
            <td><b>${Number(s.expectedPrice).toLocaleString()} đ</b></td>
            <td>${expireText}</td>
            <td>${statusBadge}</td>
            <td><b>${s.totalResponses}</b></td>
            <td style="display:flex; gap:6px;">
                <button class="btn" onclick="viewSurveyStats(${s.surveyId})">Thống kê</button>
                <button class="btn btn-warning" onclick="toggleSurveyLock(${s.surveyId})">${s.isActive ? 'Khóa' : 'Mở khóa'}</button>
                <button class="btn btn-danger" onclick="deleteSurvey(${s.surveyId})">Xóa</button>
            </td>
        </tr>
        `;
    }).join("");
}

async function createSurvey() {
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

    const body = {
        title,
        targetProduct,
        expectedPrice,
        description,
        durationType,
        durationDays: durationType === "Days" ? durationDays : null,
        expiresAt: durationType === "Date" ? expireDateVal : null
    };

    await fetch(`${CRM_API}/surveys`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });

    document.getElementById("svTitle").value = "";
    document.getElementById("svProduct").value = "";
    document.getElementById("svPrice").value = "";
    document.getElementById("svDesc").value = "";

    alert("Đã phát hành khảo sát mới.");
    await loadSurveys();
    notifyDataChanged("surveys");
}

async function toggleSurveyLock(id) {
    const res = await fetch(`${CRM_API}/surveys/${id}/toggle-lock`, { method: "PUT" });
    const data = await res.json();
    alert(data.message);
    await loadSurveys();
    notifyDataChanged("surveys");
}

async function deleteSurvey(id) {
    if (!confirm("Xác nhận xóa bảng khảo sát này và toàn bộ dữ liệu trả lời liên quan?")) return;
    const res = await fetch(`${CRM_API}/surveys/${id}`, { method: "DELETE" });
    const data = await res.json();
    if (!res.ok) return alert(data.message || "Không thể xóa khảo sát.");

    if (currentViewedSurveyId === id) {
        document.getElementById("surveyStatCard").style.display = "none";
        currentViewedSurveyId = null;
    }
    await loadSurveys();
    notifyDataChanged("surveys");
}

async function viewSurveyStats(id) {
    currentViewedSurveyId = id;
    const s = await (await fetch(`${CRM_API}/surveys/${id}/statistics`)).json();
    document.getElementById("surveyStatCard").style.display = "block";
    document.getElementById("statTitle").innerText = `Thống kê kết quả: ${s.title} (${s.targetProduct})`;
    document.getElementById("statSummary").innerText =
        `Tổng lượt trả lời: ${s.totalResponses} | Điểm trung bình: ${s.averageScore}/5.0 | Rất muốn mua: ${s.intentStats.wantToBuy} | Đang cân nhắc: ${s.intentStats.considering} | Không mua: ${s.intentStats.notBuying}`;

    document.getElementById("statResponses").innerHTML = s.detailResponses.map(r => `
        <tr>
            <td><b>${r.customerName}</b></td>
            <td><b>${r.score} / 5</b></td>
            <td>${r.buyingIntent}</td>
            <td>${r.customerOpinion || "-"}</td>
        </tr>
    `).join("");
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}