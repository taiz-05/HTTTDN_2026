const CRM_API = "http://localhost:5000/api/admin/crm";

window.onload = () => {
    const user = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!user || (user.roleName !== "Manager" && user.roleName !== "Admin")) {
        return window.location.href = "login.html";
    }
    document.getElementById("managerName").innerText = "Quản lý: " + user.fullName;
    loadCustomers();
    loadFeedbacks();
    loadDemographics();
    loadSurveys();
};

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".tab-btn").forEach(el => el.classList.remove("active"));
    document.getElementById(id).style.display = "block";
    btn.classList.add("active");
}

async function loadCustomers() {
    const list = await (await fetch(`${CRM_API}/customers`)).json();
    document.getElementById("customerList").innerHTML = list.map(c => `
        <tr>
            <td><b>${c.username}</b></td>
            <td>${c.fullName}</td>
            <td>${c.phone || ""}</td>
            <td>${c.profile?.age || "-"}</td>
            <td>${c.profile?.interest || "-"}</td>
            <td><span class="badge ${c.isActive ? 'badge-active' : 'badge-locked'}">${c.isActive ? 'Hoạt động' : 'Đã khóa'}</span></td>
            <td>
                <button class="btn btn-warning" onclick="toggleLock(${c.accountId})">${c.isActive ? 'Khóa TK' : 'Mở khóa'}</button>
                <button class="btn btn-danger" onclick="deleteCustomer(${c.accountId})">Xóa</button>
            </td>
        </tr>
    `).join("");
}

async function addCustomer() {
    const body = {
        username: document.getElementById("cUser").value,
        password: "123456",
        fullName: document.getElementById("cName").value,
        phone: document.getElementById("cPhone").value,
        age: Number(document.getElementById("cAge").value || 22),
        interest: document.getElementById("cInterest").value
    };
    const res = await fetch(`${CRM_API}/customers`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    const data = await res.json();
    alert(data.message);
    loadCustomers();
    loadDemographics();
}

async function toggleLock(id) {
    await fetch(`${CRM_API}/customers/${id}/toggle-status`, { method: "PUT" });
    loadCustomers();
}

async function deleteCustomer(id) {
    if (!confirm("Xác nhận xóa khách hàng này?")) return;
    await fetch(`${CRM_API}/customers/${id}`, { method: "DELETE" });
    loadCustomers();
    loadDemographics();
}

async function loadFeedbacks() {
    const list = await (await fetch(`${CRM_API}/feedbacks`)).json();
    document.getElementById("feedbackList").innerHTML = list.map(f => `
        <tr>
            <td><b>${f.customerName}</b></td>
            <td>${f.productName}</td>
            <td>${"⭐".repeat(f.rating)}</td>
            <td>${f.comment}</td>
            <td>${f.adminReply || "<i>Chưa phản hồi</i>"}</td>
            <td>${f.status}</td>
            <td><button class="btn" onclick="replyFeedback(${f.feedbackId})">Trả lời</button></td>
        </tr>
    `).join("");
}

async function replyFeedback(id) {
    const reply = prompt("Nhập nội dung phản hồi gửi đến khách hàng:");
    if (!reply) return;
    await fetch(`${CRM_API}/feedbacks/${id}/reply`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ adminReply: reply })
    });
    loadFeedbacks();
}

async function loadDemographics() {
    const data = await (await fetch(`${CRM_API}/reports/demographics`)).json();
    const total = data.totalCustomers || 1;
    document.getElementById("totalCus").innerText = data.totalCustomers;

    const u20 = Math.round((data.ageStats.under20 / total) * 100);
    const f20_30 = Math.round((data.ageStats.from20To30 / total) * 100);
    const o30 = Math.round((data.ageStats.over30 / total) * 100);

    document.getElementById("ageReportBox").innerHTML = `
        <div>Dưới 20 tuổi: ${data.ageStats.under20} khách (${u20}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="width:${u20}%">${u20}%</div></div>
        <div>Từ 20 - 30 tuổi: ${data.ageStats.from20To30} khách (${f20_30}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="width:${f20_30}%">${f20_30}%</div></div>
        <div>Trên 30 tuổi: ${data.ageStats.over30} khách (${o30}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="width:${o30}%">${o30}%</div></div>
    `;

    document.getElementById("interestReportBox").innerHTML = data.interestStats.map(i => `
        <div>Sở thích <b>${i.interest}</b>: ${i.count} khách (${i.percentage}%)</div>
        <div class="progress-bar"><div class="progress-fill" style="background:#0f766e; width:${i.percentage}%">${i.percentage}%</div></div>
    `).join("");
}

async function loadSurveys() {
    const list = await (await fetch(`${CRM_API}/surveys`)).json();
    document.getElementById("surveyList").innerHTML = list.map(s => `
        <tr>
            <td><b>${s.title}</b><br><small>${s.description || ""}</small></td>
            <td>${s.targetProduct}</td>
            <td>${Number(s.expectedPrice).toLocaleString()} đ</td>
            <td><b>${s.totalResponses}</b> lượt</td>
            <td><button class="btn" onclick="viewSurveyStats(${s.surveyId})">Thống kê KQ</button></td>
        </tr>
    `).join("");
}

async function createSurvey() {
    const body = {
        title: document.getElementById("svTitle").value,
        targetProduct: document.getElementById("svProduct").value,
        expectedPrice: Number(document.getElementById("svPrice").value),
        description: document.getElementById("svDesc").value
    };
    await fetch(`${CRM_API}/surveys`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    alert("Đã phát hành khảo sát tới toàn bộ tài khoản khách hàng!");
    loadSurveys();
}

async function viewSurveyStats(id) {
    const s = await (await fetch(`${CRM_API}/surveys/${id}/statistics`)).json();
    document.getElementById("surveyStatCard").style.display = "block";
    document.getElementById("statTitle").innerText = `Thống kê: ${s.title} (${s.targetProduct})`;
    document.getElementById("statSummary").innerText =
        `Tổng phản hồi: ${s.totalResponses} | Điểm TB: ${s.averageScore}/5 ⭐ | Rất muốn mua: ${s.intentStats.wantToBuy} | Đang cân nhắc: ${s.intentStats.considering} | Không mua: ${s.intentStats.notBuying}`;

    document.getElementById("statResponses").innerHTML = s.detailResponses.map(r => `
        <tr>
            <td><b>${r.customerName}</b></td>
            <td>${"⭐".repeat(r.score)} (${r.score}/5)</td>
            <td>${r.buyingIntent}</td>
            <td>${r.customerOpinion || ""}</td>
        </tr>
    `).join("");
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}