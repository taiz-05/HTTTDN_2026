const CRM_API = "http://localhost:5000/api/admin/crm";
let currentViewedSurveyId = null;
let crmStarChart = null;
let crmProdChart = null;
let agePieChartInstance = null;
let interestBarChartInstance = null;
let surveyIntentChartInstance = null;
let surveyScoreChartInstance = null;

let allCustomersCache = [];
let allFeedbacksCache = [];
let allSurveysCache = [];
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
    if (!user || user.roleName !== "Manager") {
        if (user && user.roleName === "Admin") {
            return window.location.href = "admin.html";
        }
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
            await viewSurveyStats(currentViewedSurveyId, false);
        } else if (allSurveysCache.length > 0) {
            await viewSurveyStats(allSurveysCache[0].surveyId, false);
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
        if (!res.ok) return;
        allCustomersCache = await res.json();

        const total = allCustomersCache.length;
        const activeCount = allCustomersCache.filter(c => c.isActive).length;
        const lockedCount = total - activeCount;

        if (document.getElementById("cusKpiTotal")) document.getElementById("cusKpiTotal").innerText = total;
        if (document.getElementById("cusKpiActive")) document.getElementById("cusKpiActive").innerText = activeCount;
        if (document.getElementById("cusKpiLocked")) document.getElementById("cusKpiLocked").innerText = lockedCount;

        filterCustomerList();
        renderSurveyRecipientCheckboxes();
        renderDemographicsCustomerTable();
    } catch (e) {
        console.error("Lỗi loadCustomers:", e);
    }
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
// 2. TIẾP NHẬN PHẢN HỒI CỦA KHÁCH HÀNG
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

        // Bảng phản hồi
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
    selectedFeedbackId = fb.feedbackId;
    document.getElementById("replyModalMeta").innerText = `Khách hàng: ${fb.customerName} | Sản phẩm: ${fb.productName} (${fb.rating}/5 sao)`;
    document.getElementById("replyModalComment").innerText = `"${fb.comment}"`;
    document.getElementById("replyModalText").value = fb.adminReply || "Cảm ơn quý khách đã gửi phản hồi! Hệ thống đã tiếp nhận ý kiến đóng góp của bạn.";
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
        alert("Đã tiếp nhận và gửi phản hồi cho khách hàng!");
        closeReplyModal();
        await loadFeedbacks();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi khi gửi phản hồi: " + err.message);
    }
}

// =========================================================
// 3. BÁO CÁO VỀ KHÁCH HÀNG, TỶ LỆ ĐỘ TUỔI, SỞ THÍCH
// =========================================================
async function loadDemographics() {
    try {
        const data = await (await fetch(`${CRM_API}/reports/demographics`)).json();
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
// 4. TẠO BẢNG KHẢO SÁT VÀ GỬI ĐẾN TÀI KHOẢN KHÁCH HÀNG
// =========================================================
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

    const body = {
        title,
        targetProduct,
        expectedPrice,
        description,
        durationType: durationVal === "NoLimit" ? "NoLimit" : "Days",
        durationDays: durationVal === "NoLimit" ? null : Number(durationVal),
        expiresAt: null
    };

    try {
        const res = await fetch(`${CRM_API}/surveys`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        alert(`Đã tạo bảng khảo sát "${title}" và gửi đến ${selectedAccounts.length} tài khoản khách hàng thành công!`);

        document.getElementById("inlineSvTitle").value = "";
        document.getElementById("inlineSvProduct").value = "";
        document.getElementById("inlineSvPrice").value = "";
        document.getElementById("inlineSvDesc").value = "";

        await loadSurveys();
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi tạo khảo sát: " + err.message);
    }
}

async function loadSurveys() {
    try {
        allSurveysCache = await (await fetch(`${CRM_API}/surveys`)).json();

        // Populate dropdown in Tab 5 (Thống kê kết quả khảo sát)
        const statSelect = document.getElementById("statSurveySelect");
        if (statSelect) {
            const prevVal = statSelect.value;
            statSelect.innerHTML = allSurveysCache.map(s =>
                `<option value="${s.surveyId}">#${s.surveyId} - ${s.title} (${s.targetProduct}) — ${s.totalResponses} lượt trả lời</option>`
            ).join("");
            if (prevVal && allSurveysCache.some(x => String(x.surveyId) === String(prevVal))) {
                statSelect.value = prevVal;
            }
        }

        const activeCustomerCount = allCustomersCache.filter(c => c.isActive).length || 7;

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

            return `
            <tr>
                <td>
                    <b>${s.title}</b>
                    <div style="color:var(--text-muted); font-size:11.5px; margin-top:2px;">${s.description || ""}</div>
                </td>
                <td><b style="color:#1d4ed8;">${s.targetProduct}</b></td>
                <td><b>${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫</b></td>
                <td><span class="badge badge-active">Đã gửi đến ${s.totalCustomerAccounts || activeCustomerCount} TK khách hàng</span></td>
                <td>${expireText}</td>
                <td>${statusBadge}</td>
                <td><b style="font-size:14px; color:var(--text-primary);">${s.totalResponses}</b> lượt</td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn" style="padding:4px 9px; font-size:12px;" onclick="openSurveyStatsTab(${s.surveyId})">Thống kê KQ</button>
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
        const res = await fetch(`${CRM_API}/surveys`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();

        alert(data.message || "Đã tạo bảng khảo sát và gửi đến tài khoản khách hàng thành công!");
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

        await loadSurveys();
        if (allSurveysCache.length > 0) {
            await viewSurveyStats(allSurveysCache[0].surveyId, false);
        }
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi khi xóa: " + err.message);
    }
}

// =========================================================
// 5. THỐNG KÊ KẾT QUẢ KHẢO SÁT
// =========================================================
function openSurveyStatsTab(surveyId) {
    const navBtn = document.getElementById("navTabSurveyStats");
    switchTab("tabSurveyStats", navBtn);
    viewSurveyStats(surveyId, true);
}

async function viewSurveyStats(id, syncDropdown = true) {
    if (!id) return;
    try {
        currentViewedSurveyId = id;
        if (syncDropdown && document.getElementById("statSurveySelect")) {
            document.getElementById("statSurveySelect").value = String(id);
        }

        const s = await (await fetch(`${CRM_API}/surveys/${id}/statistics`)).json();

        const total = s.totalResponses || 0;
        const wantCount = s.intentStats?.wantToBuy || 0;
        const considerCount = s.intentStats?.considering || 0;
        const notBuyCount = s.intentStats?.notBuying || 0;
        const wantPct = total > 0 ? Math.round((wantCount / total) * 100) : 0;

        if (document.getElementById("statSurveyProductBadge")) {
            document.getElementById("statSurveyProductBadge").innerText = `${s.targetProduct} (${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫)`;
        }
        if (document.getElementById("statKpiTotalResp")) {
            document.getElementById("statKpiTotalResp").innerText = `${total} khách hàng`;
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
            const dist = s.scoreDistribution || {
                score1: s.detailResponses.filter(r => r.score === 1).length,
                score2: s.detailResponses.filter(r => r.score === 2).length,
                score3: s.detailResponses.filter(r => r.score === 3).length,
                score4: s.detailResponses.filter(r => r.score === 4).length,
                score5: s.detailResponses.filter(r => r.score === 5).length
            };
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

        document.getElementById("statTitle").innerText = `Bảng Thống kê Chi tiết Khảo sát: ${s.title} (${s.targetProduct})`;
        document.getElementById("statSummary").innerText =
            `• Tổng số người phản hồi: ${total} khách hàng  |  • Điểm quan tâm trung bình: ${s.averageScore} / 5.0 ★\n` +
            `• Cơ cấu ý định mua: Rất muốn mua (${wantCount})  ·  Đang cân nhắc (${considerCount})  ·  Không mua (${notBuyCount})`;

        if (!s.detailResponses || s.detailResponses.length === 0) {
            document.getElementById("statResponses").innerHTML = `<tr><td colspan="7" style="text-align:center; padding:28px; color:var(--text-muted); font-size:13.5px;">Chưa có khách hàng nào gửi câu trả lời cho bảng khảo sát này.</td></tr>`;
        } else {
            document.getElementById("statResponses").innerHTML = s.detailResponses.map(r => {
                const dt = r.submittedAt ? new Date(r.submittedAt).toLocaleString("vi-VN") : "-";

                // Phân rã cấu trúc câu trả lời chuyên sâu
                let opinionRaw = r.customerOpinion || "";
                let priceEval = "Giá hợp lý";
                let features = "Hiệu năng mạnh mẽ, Pin trâu";
                let willingPrice = "";
                let userNotes = opinionRaw;

                const priceMatch = opinionRaw.match(/\[Đánh giá giá:\s*([^\]]+)\]/i);
                if (priceMatch) {
                    priceEval = priceMatch[1];
                    userNotes = userNotes.replace(priceMatch[0], "");
                }

                const featureMatch = opinionRaw.match(/\[Tiêu chí (?:mong đợi|ưu tiên):\s*([^\]]+)\]/i);
                if (featureMatch) {
                    features = featureMatch[1];
                    userNotes = userNotes.replace(featureMatch[0], "");
                }

                const willingMatch = opinionRaw.match(/\[Giá (?:sẵn sàng chi|kỳ vọng):\s*([^\]]+)\]/i);
                if (willingMatch) {
                    willingPrice = willingMatch[1];
                    userNotes = userNotes.replace(willingMatch[0], "");
                }

                const opinionMatch = opinionRaw.match(/\[Ý kiến:\s*([^\]]+)\]/i);
                if (opinionMatch) {
                    userNotes = opinionMatch[1];
                } else {
                    userNotes = userNotes.trim().replace(/^"/, "").replace(/"$/, "") || "Rất mong đợi sản phẩm ra mắt chính thức";
                }

                const featureChipsHtml = features.split(",")
                    .map(f => `<span class="badge-tag" style="background:#FFF7ED; color:#EA580C; border:1px solid #FFD4BF; font-size:10.5px; padding:2px 7px; border-radius:4px; margin:2px;">${f.trim()}</span>`)
                    .join(" ");

                let priceBadgeColor = "badge-active";
                if (priceEval.includes("quá đắt") || priceEval.includes("Chưa phù hợp")) priceBadgeColor = "badge-locked";
                else if (priceEval.includes("hơi cao")) priceBadgeColor = "badge-info";

                return `
                    <tr>
                        <!-- CỘT 1: KHÁCH HÀNG & TÀI KHOẢN -->
                        <td>
                            <div style="font-weight:700; color:#0F172A; font-size:13.5px; white-space:nowrap;">${r.customerName}</div>
                            <div style="font-size:12px; color:#64748B;">@${r.customerUsername || "khachhang"}</div>
                        </td>

                        <!-- CỘT 2: ĐIỂM QUAN TÂM -->
                        <td>
                            <span class="star-rating-box" style="white-space:nowrap;">
                                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                <span>${r.score}.0 / 5</span>
                            </span>
                        </td>

                        <!-- CỘT 3: ĐÁNH GIÁ MỨC GIÁ -->
                        <td>
                            <span class="badge ${priceBadgeColor}" style="white-space:nowrap;">
                                ${priceEval}
                            </span>
                        </td>

                        <!-- CỘT 4: TIÊU CHÍ MONG ĐỢI -->
                        <td>
                            <div style="display:flex; flex-wrap:wrap; gap:3px;">
                                ${featureChipsHtml}
                            </div>
                        </td>

                        <!-- CỘT 5: Ý ĐỊNH MUA SẮM -->
                        <td>
                            <span class="badge ${r.buyingIntent && (r.buyingIntent.includes('Đặt trước') || r.buyingIntent.includes('Rất muốn')) ? 'badge-active' : (r.buyingIntent && (r.buyingIntent.includes('Chưa có') || r.buyingIntent.includes('Không'))) ? 'badge-locked' : 'badge-info'}" style="white-space:nowrap;">
                                ${r.buyingIntent}
                            </span>
                        </td>

                        <!-- CỘT 6: GÓP Ý CHI TIẾT & GIÁ KỲ VỌNG -->
                        <td>
                            <div style="font-size:12.5px; color:#0F172A; line-height:1.45;">"${userNotes}"</div>
                            ${willingPrice ? `<div style="font-size:11.5px; color:#EA580C; font-weight:700; margin-top:3px;">💰 Giá kỳ vọng: ${willingPrice}</div>` : ''}
                        </td>

                        <!-- CỘT 7: THỜI GIAN -->
                        <td>
                            <div style="font-size:11.5px; color:#64748B; white-space:nowrap;">${dt}</div>
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
