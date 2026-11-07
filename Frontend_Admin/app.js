const API = "http://localhost:5000/api/admin";
const DEFAULT_IMG = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400";

let rolesList = [];
let adminProductsCache = [];
let allAccountsCache = [];
let currentUser = null;
let editingProductId = null;

let dailyTrendChartInstance = null;
let ratingChartInstance = null;
let productChartInstance = null;

// KÊNH ĐỒNG BỘ REAL-TIME GIỮA CÁC TAB TRÌNH DUYỆT
const syncChannel = new BroadcastChannel("htttdn_realtime_sync");

function notifyDataChanged(scope) {
    const payload = { scope, timestamp: Date.now() };
    syncChannel.postMessage(payload);
    localStorage.setItem("htttdn_sync_event", JSON.stringify(payload));
}

syncChannel.onmessage = () => refreshAllAdminDataSilently();
window.addEventListener("storage", (e) => {
    if (e.key === "htttdn_sync_event") refreshAllAdminDataSilently();
});
window.addEventListener("focus", () => refreshAllAdminDataSilently());

window.onload = async () => {
    currentUser = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!currentUser || currentUser.roleName !== "Admin") {
        window.location.href = "login.html";
        return;
    }

    const adminNameEl = document.getElementById("adminName");
    if (adminNameEl) {
        adminNameEl.innerText = "Tài khoản: " + currentUser.fullName + " (" + currentUser.username + ")";
    }

    // Khởi tạo mặc định bộ lọc 7 ngày gần nhất
    applyPresetDates("7days");

    await loadCategoriesAndSuppliers();
    await loadRoles();
    await refreshAllAdminDataSilently();

    setInterval(refreshAllAdminDataSilently, 4000);
};

async function refreshAllAdminDataSilently() {
    try {
        await Promise.all([
            loadProducts(),
            loadSuppliers(),
            loadAccounts()
        ]);
        await loadReviewAnalytics();
    } catch (err) {
        console.error("Lỗi tải dữ liệu Admin:", err);
    }
}

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));
    const target = document.getElementById(id);
    if (target) target.style.display = "block";
    if (btn) btn.classList.add("active");
}

// =========================================================
// 1. XỬ LÝ BỘ LỌC NGÀY & THỐNG KÊ THEO NGÀY
// =========================================================
function toLocalIsoDate(dateObj) {
    const y = dateObj.getFullYear();
    const m = String(dateObj.getMonth() + 1).padStart(2, "0");
    const d = String(dateObj.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
}

function formatDateVN(isoDateStr) {
    if (!isoDateStr) return "";
    const parts = isoDateStr.split("-");
    if (parts.length !== 3) return isoDateStr;
    return `${parts[2]}/${parts[1]}/${parts[0]}`;
}

function formatDateTimeVN(dateVal) {
    if (!dateVal) return "-";
    const d = new Date(dateVal);
    if (isNaN(d.getTime())) return "-";
    const day = String(d.getDate()).padStart(2, "0");
    const month = String(d.getMonth() + 1).padStart(2, "0");
    const year = d.getFullYear();
    const hours = String(d.getHours()).padStart(2, "0");
    const mins = String(d.getMinutes()).padStart(2, "0");
    return `${day}/${month}/${year} ${hours}:${mins}`;
}

function applyPresetDates(preset) {
    const now = new Date();
    const endInput = document.getElementById("statEndDate");
    const startInput = document.getElementById("statStartDate");
    if (!startInput || !endInput) return;

    if (preset === "today") {
        const todayStr = toLocalIsoDate(now);
        startInput.value = todayStr;
        endInput.value = todayStr;
    } else if (preset === "7days") {
        const start = new Date(now);
        start.setDate(now.getDate() - 6);
        startInput.value = toLocalIsoDate(start);
        endInput.value = toLocalIsoDate(now);
    } else if (preset === "30days") {
        const start = new Date(now);
        start.setDate(now.getDate() - 29);
        startInput.value = toLocalIsoDate(start);
        endInput.value = toLocalIsoDate(now);
    } else if (preset === "all") {
        startInput.value = "";
        endInput.value = "";
    }
}

function onStatPresetChange() {
    const preset = document.getElementById("statRangePreset").value;
    if (preset !== "custom") {
        applyPresetDates(preset);
        loadReviewAnalytics();
    }
}

function onCustomDateInput() {
    document.getElementById("statRangePreset").value = "custom";
    loadReviewAnalytics();
}

function resetDateFilter() {
    document.getElementById("statRangePreset").value = "all";
    applyPresetDates("all");
    loadReviewAnalytics();
}

async function loadReviewAnalytics() {
    try {
        const res = await fetch(`${API}/crm/feedbacks`);
        if (!res.ok) return;
        const feedbacks = await res.json();

        const startVal = document.getElementById("statStartDate")?.value || "";
        const endVal = document.getElementById("statEndDate")?.value || "";

        const filteredFeedbacks = feedbacks.filter(f => {
            if (!f.createdAt) return true;
            const fDateStr = toLocalIsoDate(new Date(f.createdAt));
            if (startVal && fDateStr < startVal) return false;
            if (endVal && fDateStr > endVal) return false;
            return true;
        });

        const rangeLabel = document.getElementById("statDateRangeLabel");
        const kpiReviewsLabel = document.getElementById("kpiReviewsLabel");
        if (rangeLabel && kpiReviewsLabel) {
            if (!startVal && !endVal) {
                rangeLabel.innerText = "Đang xem: Tất cả thời gian";
                kpiReviewsLabel.innerText = "Tổng lượt đánh giá";
            } else if (startVal === endVal) {
                rangeLabel.innerText = `Ngày: ${formatDateVN(startVal)}`;
                kpiReviewsLabel.innerText = `Đánh giá ngày ${formatDateVN(startVal)}`;
            } else {
                rangeLabel.innerText = `Từ ${formatDateVN(startVal || "...")} đến ${formatDateVN(endVal || "...")}`;
                kpiReviewsLabel.innerText = "Lượt đánh giá (Trong kỳ)";
            }
        }

        document.getElementById("kpiReviews").innerText = filteredFeedbacks.length;
        const badgeEl = document.getElementById("dailySummaryBadge");
        if (badgeEl) badgeEl.innerText = `${filteredFeedbacks.length} đánh giá trong kỳ`;

        const avg = filteredFeedbacks.length > 0
            ? (filteredFeedbacks.reduce((sum, f) => sum + f.rating, 0) / filteredFeedbacks.length).toFixed(1)
            : "0.0";
        document.getElementById("kpiAvgStar").innerText = `Điểm TB: ${avg} / 5.0`;

        // 1. Biểu đồ theo ngày
        let dateKeys = [];
        if (startVal && endVal && startVal <= endVal) {
            let cur = new Date(startVal + "T00:00:00");
            const last = new Date(endVal + "T00:00:00");
            while (cur <= last && dateKeys.length < 31) {
                dateKeys.push(toLocalIsoDate(cur));
                cur.setDate(cur.getDate() + 1);
            }
        } else {
            const now = new Date();
            for (let i = 6; i >= 0; i--) {
                const d = new Date(now);
                d.setDate(now.getDate() - i);
                dateKeys.push(toLocalIsoDate(d));
            }
            feedbacks.forEach(f => {
                if (f.createdAt) {
                    const k = toLocalIsoDate(new Date(f.createdAt));
                    if (!dateKeys.includes(k)) dateKeys.push(k);
                }
            });
            dateKeys.sort();
        }

        const dailyReviewCounts = dateKeys.map(k =>
            feedbacks.filter(f => f.createdAt && toLocalIsoDate(new Date(f.createdAt)) === k).length
        );

        const dailyAccountCounts = dateKeys.map(k =>
            allAccountsCache.filter(a => a.createdAt && toLocalIsoDate(new Date(a.createdAt)) === k).length
        );

        const dailyCanvas = document.getElementById("dailyTrendChart");
        if (dailyCanvas && typeof Chart !== "undefined") {
            const ctxDaily = dailyCanvas.getContext("2d");
            if (dailyTrendChartInstance) dailyTrendChartInstance.destroy();
            dailyTrendChartInstance = new Chart(ctxDaily, {
                type: "bar",
                data: {
                    labels: dateKeys.map(k => formatDateVN(k)),
                    datasets: [
                        {
                            type: "line",
                            label: "Số lượt đánh giá trong ngày",
                            data: dailyReviewCounts,
                            borderColor: "#1e3a8a",
                            backgroundColor: "rgba(30, 58, 138, 0.12)",
                            borderWidth: 2.5,
                            pointBackgroundColor: "#1e3a8a",
                            pointRadius: 4,
                            tension: 0.25,
                            fill: true
                        },
                        {
                            type: "bar",
                            label: "Tài khoản đăng ký mới",
                            data: dailyAccountCounts,
                            backgroundColor: "#65a30d",
                            borderRadius: 4,
                            barThickness: 22
                        }
                    ]
                },
                options: {
                    animation: false,
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: "top" } },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        }

        // 2. Biểu đồ cột 1-5 sao
        const starCounts = [1, 2, 3, 4, 5].map(star => filteredFeedbacks.filter(f => f.rating === star).length);
        const barCanvas = document.getElementById("ratingBarChart");
        if (barCanvas && typeof Chart !== "undefined") {
            const ctxBar = barCanvas.getContext("2d");
            if (ratingChartInstance) ratingChartInstance.destroy();
            ratingChartInstance = new Chart(ctxBar, {
                type: "bar",
                data: {
                    labels: ["1 Sao", "2 Sao", "3 Sao", "4 Sao", "5 Sao"],
                    datasets: [{
                        label: "Số lượt đánh giá",
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
        }

        // 3. Biểu đồ tròn sản phẩm
        const prodMap = {};
        filteredFeedbacks.forEach(f => {
            const name = f.productName || "Khác";
            prodMap[name] = (prodMap[name] || 0) + 1;
        });

        const pieCanvas = document.getElementById("productReviewChart");
        if (pieCanvas && typeof Chart !== "undefined") {
            const ctxPie = pieCanvas.getContext("2d");
            if (productChartInstance) productChartInstance.destroy();
            productChartInstance = new Chart(ctxPie, {
                type: "doughnut",
                data: {
                    labels: Object.keys(prodMap).length > 0 ? Object.keys(prodMap) : ["Chưa có đánh giá"],
                    datasets: [{
                        data: Object.keys(prodMap).length > 0 ? Object.values(prodMap) : [1],
                        backgroundColor: Object.keys(prodMap).length > 0
                            ? ["#1e3a8a", "#65a30d", "#0284c7", "#d97706", "#4f46e5"]
                            : ["#e5e7eb"]
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

        // 4. Bảng danh sách phản hồi
        const countEl = document.getElementById("tableCountText");
        if (countEl) countEl.innerText = `Hiển thị ${filteredFeedbacks.length} kết quả`;

        const tbody = document.getElementById("recentReviewsTable");
        if (tbody) {
            if (filteredFeedbacks.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" style="text-align:center; color:var(--text-muted); padding:18px;">
                            Không có đánh giá nào trong khoảng ngày đã chọn.
                        </td>
                    </tr>
                `;
            } else {
                tbody.innerHTML = filteredFeedbacks.map(f => `
                    <tr>
                        <td><span class="badge badge-info">${formatDateTimeVN(f.createdAt)}</span></td>
                        <td><b>${f.customerName}</b></td>
                        <td>${f.productName}</td>
                        <td><b>${f.rating} / 5</b></td>
                        <td>${f.comment}</td>
                        <td><span class="badge ${f.status.includes('Đã') ? 'badge-active' : 'badge-locked'}">${f.status}</span></td>
                    </tr>
                `).join("");
            }
        }
    } catch (e) {
        console.error("Lỗi loadReviewAnalytics:", e);
    }
}

// =========================================================
// 2. QUẢN LÝ SẢN PHẨM & DANH MỤC
// =========================================================
async function loadCategoriesAndSuppliers() {
    try {
        const cats = await (await fetch(`${API}/categories`)).json();
        const sups = await (await fetch(`${API}/suppliers`)).json();

        const fCat = document.getElementById("fCategory"),
              pCat = document.getElementById("pCat"),
              editCat = document.getElementById("editProdCat");

        if (fCat && pCat && editCat) {
            const curFCat = fCat.value;
            fCat.innerHTML = `<option value="">Tất cả danh mục</option>`;
            pCat.innerHTML = "";
            editCat.innerHTML = "";

            cats.forEach(c => {
                const opt = `<option value="${c.categoryId}">${c.categoryName}</option>`;
                fCat.innerHTML += opt;
                pCat.innerHTML += opt;
                editCat.innerHTML += opt;
            });
            fCat.value = curFCat;
        }

        const fSup = document.getElementById("fSupplier"),
              pSup = document.getElementById("pSup"),
              editSup = document.getElementById("editProdSup");

        if (fSup && pSup && editSup) {
            const curFSup = fSup.value;
            fSup.innerHTML = `<option value="">Tất cả nhà cung cấp</option>`;
            pSup.innerHTML = "";
            editSup.innerHTML = "";

            sups.forEach(s => {
                const opt = `<option value="${s.supplierId}">${s.supplierName}</option>`;
                fSup.innerHTML += opt;
                pSup.innerHTML += opt;
                editSup.innerHTML += opt;
            });
            fSup.value = curFSup;
        }
    } catch (e) {
        console.error("Lỗi loadCategoriesAndSuppliers:", e);
    }
}

function resetProductFilter() {
    document.getElementById("fKeyword").value = "";
    document.getElementById("fCategory").value = "";
    document.getElementById("fSupplier").value = "";
    document.getElementById("fStatus").value = "";
    document.getElementById("fMinPrice").value = "";
    document.getElementById("fMaxPrice").value = "";
    document.getElementById("fSort").value = "";
    loadProducts();
}

async function loadProducts() {
    try {
        const params = new URLSearchParams({
            keyword: document.getElementById("fKeyword")?.value.trim() || "",
            categoryId: document.getElementById("fCategory")?.value || "",
            supplierId: document.getElementById("fSupplier")?.value || "",
            status: document.getElementById("fStatus")?.value || "",
            minPrice: document.getElementById("fMinPrice")?.value || "",
            maxPrice: document.getElementById("fMaxPrice")?.value || "",
            sortBy: document.getElementById("fSort")?.value || ""
        });
        const res = await fetch(`${API}/products?${params}`);
        if (!res.ok) return;
        adminProductsCache = await res.json();
        document.getElementById("kpiProducts").innerText = adminProductsCache.length;

        document.getElementById("productTable").innerHTML = adminProductsCache.map(p => {
            const badgeClass = p.status === "Đang bán" ? "badge-active" : "badge-locked";
            return `
            <tr>
                <td><img src="${p.imageUrl || DEFAULT_IMG}" class="prod-thumb" alt="${p.productName}" onerror="this.src='${DEFAULT_IMG}'"></td>
                <td><b>${p.productCode}</b></td>
                <td><b>${p.productName}</b></td>
                <td>${p.categoryName}</td>
                <td>${p.supplierName}</td>
                <td><b>${Number(p.price).toLocaleString()} đ</b></td>
                <td><b>${p.stockQuantity}</b> <span class="badge ${badgeClass}" style="margin-left:4px;">${p.status}</span></td>
                <td><b>${Number(p.avgRating ?? 5).toFixed(1)} / 5</b> (${p.reviewCount ?? 0})</td>
                <td style="display:flex; gap:6px;">
                    <button class="btn" onclick="openEditProductModal(${p.productId})">Sửa</button>
                    <button class="btn btn-danger" onclick="deleteProduct(${p.productId})">Xóa</button>
                </td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadProducts:", e);
    }
}

async function createProduct() {
    const code = document.getElementById("pCode").value.trim();
    const name = document.getElementById("pName").value.trim();
    if (!code || !name) return alert("Vui lòng nhập mã và tên sản phẩm.");

    const stock = Number(document.getElementById("pStock").value || 0);
    const body = {
        productCode: code,
        productName: name,
        categoryId: Number(document.getElementById("pCat").value),
        supplierId: Number(document.getElementById("pSup").value),
        price: Number(document.getElementById("pPrice").value || 0),
        costPrice: Number(document.getElementById("pPrice").value || 0) * 0.8,
        stockQuantity: stock,
        unit: "Cái",
        status: stock > 0 ? "Đang bán" : "Hết hàng",
        imageUrl: document.getElementById("pImage").value.trim()
    };
    const res = await fetch(`${API}/products`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    const data = await res.json();
    if (!res.ok) return alert(data.message || "Lỗi thêm sản phẩm.");

    document.getElementById("pCode").value = "";
    document.getElementById("pName").value = "";
    document.getElementById("pPrice").value = "";
    document.getElementById("pStock").value = "";
    document.getElementById("pImage").value = "";

    await loadProducts();
    notifyDataChanged("products");
}

function openEditProductModal(productId) {
    const p = adminProductsCache.find(x => x.productId === productId);
    if (!p) return;

    editingProductId = p.productId;
    document.getElementById("editProdCode").value = p.productCode;
    document.getElementById("editProdName").value = p.productName;
    document.getElementById("editProdCat").value = p.categoryId;
    document.getElementById("editProdSup").value = p.supplierId;
    document.getElementById("editProdPrice").value = p.price;
    document.getElementById("editProdStock").value = p.stockQuantity;
    document.getElementById("editProdStatus").value = p.status || "Đang bán";
    document.getElementById("editProdImage").value = p.imageUrl || "";
    document.getElementById("editProdPreviewImg").src = p.imageUrl || DEFAULT_IMG;

    document.getElementById("editProductModal").classList.add("show");
}

function closeEditProductModal() {
    document.getElementById("editProductModal").classList.remove("show");
}

async function saveEditProduct() {
    const code = document.getElementById("editProdCode").value.trim();
    const name = document.getElementById("editProdName").value.trim();
    if (!code || !name) return alert("Mã và tên sản phẩm không được để trống.");

    const price = Number(document.getElementById("editProdPrice").value || 0);
    const stock = Number(document.getElementById("editProdStock").value || 0);
    const status = document.getElementById("editProdStatus").value;

    const body = {
        productCode: code,
        productName: name,
        categoryId: Number(document.getElementById("editProdCat").value),
        supplierId: Number(document.getElementById("editProdSup").value),
        price: price,
        costPrice: price * 0.8,
        stockQuantity: stock,
        unit: "Cái",
        status: status,
        imageUrl: document.getElementById("editProdImage").value.trim()
    };

    const res = await fetch(`${API}/products/${editingProductId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    const data = await res.json();
    if (!res.ok) return alert(data.message || "Lỗi cập nhật sản phẩm.");

    closeEditProductModal();
    await loadProducts();
    notifyDataChanged("products");
    alert(data.message);
}

async function deleteProduct(id) {
    if (!confirm("Xác nhận xóa sản phẩm này?")) return;
    await fetch(`${API}/products/${id}`, { method: "DELETE" });
    await loadProducts();
    notifyDataChanged("products");
}

// =========================================================
// 3. QUẢN LÝ NHÀ CUNG CẤP
// =========================================================
async function loadSuppliers() {
    try {
        const kw = document.getElementById("sSearchKeyword") ? document.getElementById("sSearchKeyword").value.trim() : "";
        const res = await fetch(`${API}/suppliers?keyword=${encodeURIComponent(kw)}`);
        if (!res.ok) return;
        const list = await res.json();
        document.getElementById("kpiSuppliers").innerText = list.length;

        document.getElementById("supplierTable").innerHTML = list.map(s => `
            <tr>
                <td><b>${s.supplierCode}</b></td>
                <td><b>${s.supplierName}</b></td>
                <td>${s.phone || "-"}</td>
                <td>${s.address || "-"}</td>
                <td><button class="btn btn-danger" onclick="deleteSupplier(${s.supplierId})">Xóa</button></td>
            </tr>
        `).join("");
    } catch (e) {
        console.error("Lỗi loadSuppliers:", e);
    }
}

async function createSupplier() {
    const code = document.getElementById("sCode").value.trim();
    const name = document.getElementById("sName").value.trim();
    if (!code || !name) return alert("Vui lòng nhập mã và tên nhà cung cấp.");

    const body = {
        supplierCode: code,
        supplierName: name,
        phone: document.getElementById("sPhone").value.trim(),
        address: document.getElementById("sAddress").value.trim()
    };
    await fetch(`${API}/suppliers`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    document.getElementById("sCode").value = "";
    document.getElementById("sName").value = "";
    document.getElementById("sPhone").value = "";
    document.getElementById("sAddress").value = "";
    await loadSuppliers();
    await loadCategoriesAndSuppliers();
    notifyDataChanged("suppliers");
}

async function deleteSupplier(id) {
    if (!confirm("Xác nhận xóa nhà cung cấp này?")) return;
    await fetch(`${API}/suppliers/${id}`, { method: "DELETE" });
    await loadSuppliers();
    await loadCategoriesAndSuppliers();
    notifyDataChanged("suppliers");
}

// =========================================================
// 4. QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN (CHỈ ADMIN, MANAGER, CUSTOMER)
// =========================================================
async function loadRoles() {
    try {
        const res = await fetch(`${API}/accounts/roles`);
        if (!res.ok) return;
        const allRoles = await res.json();
        const allowed = ["Admin", "Manager", "Customer"];
        rolesList = allRoles.filter(r => allowed.includes(r.roleName));
        document.getElementById("aRole").innerHTML = rolesList.map(r => `<option value="${r.roleId}">${r.roleName}</option>`).join("");
    } catch (e) {
        console.error("Lỗi loadRoles:", e);
    }
}

async function loadAccounts() {
    try {
        const res = await fetch(`${API}/accounts`);
        if (!res.ok) return;
        allAccountsCache = await res.json();
        document.getElementById("kpiAccounts").innerText = allAccountsCache.length;

        document.getElementById("accountTable").innerHTML = allAccountsCache.map(a => {
            const isSelf = currentUser && a.accountId === currentUser.accountId;

            return `
            <tr>
                <td>${a.accountId}</td>
                <td><b>${a.username}</b> ${isSelf ? '<span class="badge badge-active">Đang đăng nhập</span>' : ''}</td>
                <td>${a.fullName}</td>
                <td>${a.email || "-"}</td>
                <td>
                    <select onchange="changeRole(${a.accountId}, this.value)">
                        ${rolesList.map(r => `<option value="${r.roleId}" ${r.roleId === a.roleId ? "selected" : ""}>${r.roleName}</option>`).join("")}
                    </select>
                </td>
                <td>
                    <button class="btn btn-danger" onclick="deleteAccount(${a.accountId}, ${isSelf})">
                        ${isSelf ? 'Tự xóa TK' : 'Xóa'}
                    </button>
                </td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadAccounts:", e);
    }
}

async function createAccount() {
    const username = document.getElementById("aUser").value.trim();
    const fullName = document.getElementById("aName").value.trim();
    if (!username || !fullName) return alert("Vui lòng nhập Username và Họ tên.");

    const body = {
        username,
        fullName,
        email: document.getElementById("aEmail").value.trim(),
        roleId: Number(document.getElementById("aRole").value)
    };
    const res = await fetch(`${API}/accounts`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    const data = await res.json();
    if (!res.ok) return alert(data.message || "Lỗi tạo tài khoản.");
    document.getElementById("aUser").value = "";
    document.getElementById("aName").value = "";
    document.getElementById("aEmail").value = "";
    await loadAccounts();
    notifyDataChanged("accounts");
}

async function changeRole(accountId, roleId) {
    const res = await fetch(`${API}/accounts/${accountId}/role`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ roleId: Number(roleId) })
    });
    const data = await res.json();
    alert(data.message);
    await loadAccounts();
    notifyDataChanged("accounts");
}

async function deleteAccount(id, isSelf) {
    const msg = isSelf
        ? "Bạn đang xóa tài khoản Admin đang đăng nhập của chính mình. Sau khi xóa hệ thống sẽ đăng xuất. Tiếp tục?"
        : "Xác nhận xóa tài khoản này?";

    if (!confirm(msg)) return;

    const res = await fetch(`${API}/accounts/${id}`, { method: "DELETE" });
    const data = await res.json();
    if (!res.ok) return alert(data.message || "Không thể xóa tài khoản.");

    alert(data.message);
    notifyDataChanged("accounts");
    if (isSelf) logout();
    else loadAccounts();
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}