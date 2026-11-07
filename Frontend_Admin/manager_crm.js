const CRM_API = "http://localhost:5000/api/admin/crm";
let currentViewedSurveyId = null;
let crmStarChart = null;
let crmProdChart = null;
let allCustomersCache = [];
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
    const mgrEl = document.getElementById("managerName");
    if (mgrEl) {
        mgrEl.innerText = `${user.fullName} (${user.username})`;
    }
    await refreshCrmDataSilently();
};

async function refreshCrmDataSilently() {
    try {
        await Promise.all([
            loadCustomers(),
            loadFeedbacks(),
            loadDemographics(),
            loadSurveys()
        ]);
        if (currentViewedSurveyId) {
            await viewSurveyStats(currentViewedSurveyId);
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
    if (id === "tabFeedbacks") {
        setTimeout(loadFeedbacks, 50);
    }
}

// =========================================================
// 1. QUẢN LÝ KHÁCH HÀNG (MỤC III.4.1 - 4.1.3)
// =========================================================
async function loadCustomers() {
    try {
        const res = await fetch(`${CRM_API}/customers`);
        if (!res.ok) return;
        allCustomersCache = await res.json();
        renderCustomersTable(allCustomersCache);
    } catch (e) {
        console.error("Lỗi loadCustomers:", e);
    }
}

function filterCustomerList() {
    const kw = document.getElementById("cusSearchInput")?.value.trim().toLowerCase() || "";
    const ageFilter = document.getElementById("cusFilterAge")?.value || "";
    const interestFilter = document.getElementById("cusFilterInterest")?.value || "";

    const filtered = allCustomersCache.filter(c => {
        // Keyword
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

        return true;
    });

    renderCustomersTable(filtered);
}

function resetCustomerFilter() {
    document.getElementById("cusSearchInput").value = "";
    document.getElementById("cusFilterAge").value = "";
    document.getElementById("cusFilterInterest").value = "";
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
            if (age < 20) ageLabel = `${age} tuổi <span class="badge-tag" style="background:#dbeafe; color:#1e40af;">Gen Z</span>`;
            else if (age <= 30) ageLabel = `${age} tuổi <span class="badge-tag" style="background:#e0e7ff; color:#3730a3;">Thanh niên</span>`;
            else ageLabel = `${age} tuổi <span class="badge-tag" style="background:#fef3c7; color:#92400e;">Trung niên</span>`;
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
                <td>${c.phone || "-"}</td>
                <td>${ageLabel}</td>
                <td>${interestTag}</td>
                <td><small style="color:var(--text-muted);">${c.profile?.address || "TP. Hồ Chí Minh"}</small></td>
                <td><span class="badge ${c.isActive ? 'badge-active' : 'badge-locked'}">${c.isActive ? 'Hoạt động' : 'Đã khóa'}</span></td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn btn-warning" style="padding:4px 9px; font-size:12px;" onclick="toggleLock(${c.accountId})">
                            ${c.isActive ? 'Khóa' : 'Mở khóa'}
                        </button>
                        <button class="btn btn-danger" style="padding:4px 9px; font-size:12px;" onclick="deleteCustomer(${c.accountId})">Xóa</button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
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
        alert(data.message || "Đã thêm khách hàng thành công!");
        closeCustomerModal();
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi thêm khách hàng: " + err.message);
    }
}

async function toggleLock(id) {
    try {
        await fetch(`${CRM_API}/customers/${id}/toggle-status`, { method: "PUT" });
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi đổi trạng thái: " + err.message);
    }
}

async function deleteCustomer(id) {
    if (!confirm("Xác nhận xóa hồ sơ khách hàng này khỏi hệ thống?")) return;
    try {
        const res = await fetch(`${CRM_API}/customers/${id}`, { method: "DELETE" });
        const data = await res.json();
        alert(data.message || "Đã xóa khách hàng.");
        await refreshCrmDataSilently();
        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi khi xóa: " + err.message);
    }
}

// =========================================================
// 2. TIẾP NHẬN PHẢN HỒI (MỤC III.4.4)
// =========================================================
async function loadFeedbacks() {
    try {
        allFeedbacksCache = await (await fetch(`${CRM_API}/feedbacks`)).json();

        const total = allFeedbacksCache.length;
        const answered = allFeedbacksCache.filter(f => f.adminReply && f.adminReply.trim().length > 0).length;
        const pending = total - answered;
        const avgScore = total > 0
            ? (allFeedbacksCache.reduce((sum, f) => sum + f.rating, 0) / total).toFixed(1)
            : "5.0";

        if (document.getElementById("crmKpiTotal")) document.getElementById("crmKpiTotal").innerText = total;
        if (document.getElementById("crmKpiAnswered")) document.getElementById("crmKpiAnswered").innerText = answered;
        if (document.getElementById("crmKpiPending")) document.getElementById("crmKpiPending").innerText = pending;
        if (document.getElementById("crmKpiAvg")) document.getElementById("crmKpiAvg").innerText = `${avgScore} / 5.0`;
        if (document.getElementById("crmTotalReviewsBadge")) document.getElementById("crmTotalReviewsBadge").innerText = `${total} phản hồi`;

        // Chart 1: Sao
        const starCounts = [1, 2, 3, 4, 5].map(s => allFeedbacksCache.filter(f => f.rating === s).length);
        const ctx1 = document.getElementById("crmRatingBarChart").getContext("2d");
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

        // Chart 2: Sản phẩm
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

        // Table
        document.getElementById("feedbackList").innerHTML = allFeedbacksCache.map(f => {
            const hasReply = f.adminReply && f.adminReply.trim().length > 0;
            return `
                <tr>
                    <td><b>${f.customerName}</b></td>
                    <td>${f.productName}</td>
                    <td>
                        <span class="star-rating-box">
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <span>${f.rating}.0 / 5</span>
                        </span>
                    </td>
                    <td>${f.comment}</td>
                    <td>
                        ${hasReply ? `<div class="review-reply-box" style="margin-top:0;">${f.adminReply}</div>` : `<span style="color:var(--text-muted); font-size:12px;">Chờ phản hồi...</span>`}
                    </td>
                    <td>
                        <span class="badge ${hasReply ? 'badge-active' : 'badge-locked'}">
                            ${hasReply ? 'Đã giải đáp' : 'Chờ xử lý'}
                        </span>
                    </td>
                    <td style="text-align:center;">
                        <button class="btn" style="padding:4px 10px; font-size:12px;" onclick="openReplyModal(${f.feedbackId})">
                            ${hasReply ? 'Sửa trả lời' : 'Giải đáp'}
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

    try {
        await fetch(`${CRM_API}/feedbacks/${selectedFeedbackId}/reply`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ adminReply: reply })
        });
        closeReplyModal();
        await loadFeedbacks();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi khi gửi phản hồi: " + err.message);
    }
}

// =========================================================
// 3. BÁO CÁO ĐỘ TUỔI, SỞ THÍCH (MỤC III.4.5)
// =========================================================
async function loadDemographics() {
    try {
        const data = await (await fetch(`${CRM_API}/reports/demographics`)).json();
        const total = data.totalCustomers || 1;
        document.getElementById("totalCus").innerText = data.totalCustomers;

        const u20 = Math.round((data.ageStats.under20 / total) * 100);
        const f20_30 = Math.round((data.ageStats.from20To30 / total) * 100);
        const o30 = Math.round((data.ageStats.over30 / total) * 100);

        document.getElementById("ageReportBox").innerHTML = `
            <div style="margin-bottom:12px;">
                <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                    <span>Dưới 20 tuổi (Gen Z - Sinh viên):</span>
                    <b>${data.ageStats.under20} người (${u20}%)</b>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${u20}%; background:#2563eb;"></div></div>
            </div>

            <div style="margin-bottom:12px;">
                <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                    <span>Từ 20 - 30 tuổi (Thanh niên - Đi làm):</span>
                    <b>${data.ageStats.from20To30} người (${f20_30}%)</b>
                </div>
                <div class="progress-bar"><div class="progress-fill" style="width:${f20_30}%; background:#059669;"></div></div>
            </div>

            <div>
                <div style="display:flex; justify-content:space-between; font-weight:600; font-size:13px;">
                    <span>Trên 30 tuổi (Thu nhập cao - Chuyên gia):</span>
                    <b>${data.ageStats.over30} người (${o30}%)</b>
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
                        <span>Nhóm <b>${i.interest}</b>:</span>
                        <b>${i.count} khách hàng (${i.percentage}%)</b>
                    </div>
                    <div class="progress-bar"><div class="progress-fill" style="background:${c}; width:${i.percentage}%"></div></div>
                </div>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadDemographics:", e);
    }
}

// =========================================================
// 4. KHẢO SÁT SẢN PHẨM MỚI (MỤC III.4.6 & 4.7)
// =========================================================
async function loadSurveys() {
    try {
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
                statusBadge = `<span class="badge badge-locked">Đã kết thúc</span>`;
            } else {
                statusBadge = `<span class="badge badge-active">Đang mở</span>`;
            }

            return `
            <tr>
                <td>
                    <b>${s.title}</b>
                    <div style="color:var(--text-muted); font-size:11.5px; margin-top:2px;">${s.description || ""}</div>
                </td>
                <td><b style="color:#1d4ed8;">${s.targetProduct}</b></td>
                <td><b>${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫</b></td>
                <td>${expireText}</td>
                <td>${statusBadge}</td>
                <td><b style="font-size:14px; color:var(--text-primary);">${s.totalResponses}</b> lượt</td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn" style="padding:4px 9px; font-size:12px;" onclick="viewSurveyStats(${s.surveyId})">Thống kê</button>
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

    const body = {
        title,
        targetProduct,
        expectedPrice,
        description,
        durationType,
        durationDays: durationType === "Days" ? durationDays : null,
        expiresAt: durationType === "Date" ? expireDateVal : null
    };

    try {
        await fetch(`${CRM_API}/surveys`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });

        alert("Đã phát hành bài khảo sát mới thành công!");
        closeCreateSurveyModal();
        await loadSurveys();
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

        if (currentViewedSurveyId === id) {
            document.getElementById("surveyStatCard").style.display = "none";
            currentViewedSurveyId = null;
        }
        await loadSurveys();
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi khi xóa: " + err.message);
    }
}

async function viewSurveyStats(id) {
    try {
        currentViewedSurveyId = id;
        const s = await (await fetch(`${CRM_API}/surveys/${id}/statistics`)).json();
        const card = document.getElementById("surveyStatCard");
        card.style.display = "block";
        card.scrollIntoView({ behavior: "smooth", block: "nearest" });

        document.getElementById("statTitle").innerText = `Thống kê kết quả khảo sát: ${s.title} (${s.targetProduct})`;
        document.getElementById("statSummary").innerText =
            `• Tổng số người phản hồi: ${s.totalResponses} khách hàng  |  • Điểm quan tâm trung bình: ${s.averageScore} / 5.0 ★\n` +
            `• Cơ cấu ý định mua: Rất muốn mua (${s.intentStats.wantToBuy})  ·  Đang cân nhắc (${s.intentStats.considering})  ·  Không mua (${s.intentStats.notBuying})`;

        document.getElementById("statResponses").innerHTML = s.detailResponses.map(r => `
            <tr>
                <td><b>${r.customerName}</b></td>
                <td>
                    <span class="star-rating-box">
                        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span>${r.score}.0 / 5</span>
                    </span>
                </td>
                <td>
                    <span class="badge ${r.buyingIntent === 'Rất muốn mua' ? 'badge-active' : r.buyingIntent === 'Đang cân nhắc' ? 'badge-info' : 'badge-locked'}">
                        ${r.buyingIntent}
                    </span>
                </td>
                <td>${r.customerOpinion || "<i style='color:var(--text-muted);'>Không có ý kiến thêm</i>"}</td>
            </tr>
        `).join("");
    } catch (e) {
        console.error("Lỗi viewSurveyStats:", e);
    }
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}
