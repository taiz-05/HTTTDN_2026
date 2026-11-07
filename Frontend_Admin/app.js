const API = "http://localhost:5000/api/admin";
const DEFAULT_IMG = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400";

let rolesList = [];
let categoriesList = [];
let suppliersList = [];
let adminProductsCache = [];
let allAccountsCache = [];
let currentAccountRoleFilter = "all";
let currentUser = null;
let editingProductId = null;
let editingSupplierId = null;

let dailyTrendChartInstance = null;
let ratingChartInstance = null;
let categoryChartInstance = null;
let productChartInstance = null;
let stockChartInstance = null;

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
        adminNameEl.innerText = `${currentUser.fullName} (${currentUser.username})`;
    }

    // Khởi tạo mặc định bộ lọc 7 ngày gần nhất
    applyPresetDates("7days");

    await loadCategoriesAndSuppliers();
    await loadRoles();
    await refreshAllAdminDataSilently();
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
    if (id === "tabDashboard") {
        setTimeout(loadReviewAnalytics, 50);
    }
}

// =========================================================
// 1. XỬ LÝ BỘ LỌC NGÀY & THỐNG KÊ DOANH NGHIỆP
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
        if (rangeLabel) {
            if (!startVal && !endVal) {
                rangeLabel.innerText = "Đang xem: Tất cả thời gian";
            } else if (startVal === endVal) {
                rangeLabel.innerText = `Ngày: ${formatDateVN(startVal)}`;
            } else {
                rangeLabel.innerText = `Từ ${formatDateVN(startVal || "...")} đến ${formatDateVN(endVal || "...")}`;
            }
        }

        // 1. TÍNH TOÁN 6 KPI DOANH NGHIỆP
        const totalProds = adminProductsCache.length;
        const activeProds = adminProductsCache.filter(p => p.status === "Đang bán").length;
        const outProds = adminProductsCache.filter(p => p.stockQuantity === 0).length;
        const totalInventoryValue = adminProductsCache.reduce((sum, p) => sum + (p.price * p.stockQuantity), 0);
        const totalStockUnits = adminProductsCache.reduce((sum, p) => sum + p.stockQuantity, 0);

        if (document.getElementById("kpiProducts")) document.getElementById("kpiProducts").innerText = totalProds;
        if (document.getElementById("kpiProductsSub")) document.getElementById("kpiProductsSub").innerText = `${activeProds} Đang bán · ${outProds} Hết hàng`;
        if (document.getElementById("kpiInventoryVal")) document.getElementById("kpiInventoryVal").innerText = totalInventoryValue.toLocaleString("vi-VN") + " ₫";
        if (document.getElementById("kpiSuppliers")) document.getElementById("kpiSuppliers").innerText = suppliersList.length;
        if (document.getElementById("kpiReviews")) document.getElementById("kpiReviews").innerText = filteredFeedbacks.length;

        const avg = filteredFeedbacks.length > 0
            ? (filteredFeedbacks.reduce((sum, f) => sum + f.rating, 0) / filteredFeedbacks.length).toFixed(1)
            : "5.0";
        if (document.getElementById("kpiAvgStarText")) document.getElementById("kpiAvgStarText").innerText = `Điểm TB: ${avg} / 5.0 ★`;
        if (document.getElementById("kpiAvgStar")) document.getElementById("kpiAvgStar").innerText = `Điểm TB: ${avg} / 5.0`;

        const positiveCount = filteredFeedbacks.filter(f => f.rating >= 4).length;
        const posRate = filteredFeedbacks.length > 0
            ? ((positiveCount / filteredFeedbacks.length) * 100).toFixed(1)
            : "100.0";
        if (document.getElementById("kpiPosRate")) document.getElementById("kpiPosRate").innerText = `${posRate}%`;

        if (document.getElementById("dailySummaryBadge")) {
            document.getElementById("dailySummaryBadge").innerText = `${filteredFeedbacks.length} đánh giá trong kỳ`;
        }
        if (document.getElementById("stockSummaryBadge")) {
            document.getElementById("stockSummaryBadge").innerText = `Tổng tồn: ${totalStockUnits} cái`;
        }

        // 2. BIỂU ĐỒ 1: DIỄN BIẾN THEO NGÀY (LINE + BAR)
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
                            label: "Lượt đánh giá sản phẩm",
                            data: dailyReviewCounts,
                            borderColor: "#2563eb",
                            backgroundColor: "rgba(37, 99, 235, 0.12)",
                            borderWidth: 2.5,
                            pointBackgroundColor: "#1d4ed8",
                            pointRadius: 4.5,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            type: "bar",
                            label: "Tài khoản mới đăng ký",
                            data: dailyAccountCounts,
                            backgroundColor: "#059669",
                            borderRadius: 4,
                            barThickness: 20
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

        // 3. BIỂU ĐỒ 2: CỘT MỨC SAO 1-5
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
                        backgroundColor: ["#dc2626", "#ea580c", "#f59e0b", "#2563eb", "#059669"],
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

        // 4. BIỂU ĐỒ 3: CƠ CẤU THEO DANH MỤC
        const catMap = {};
        adminProductsCache.forEach(p => {
            const cat = p.categoryName || "Khác";
            catMap[cat] = (catMap[cat] || 0) + 1;
        });

        const catCanvas = document.getElementById("categoryChart");
        if (catCanvas && typeof Chart !== "undefined") {
            const ctxCat = catCanvas.getContext("2d");
            if (categoryChartInstance) categoryChartInstance.destroy();
            categoryChartInstance = new Chart(ctxCat, {
                type: "doughnut",
                data: {
                    labels: Object.keys(catMap).length > 0 ? Object.keys(catMap) : ["Chưa có dữ liệu"],
                    datasets: [{
                        data: Object.keys(catMap).length > 0 ? Object.values(catMap) : [1],
                        backgroundColor: ["#2563eb", "#059669", "#7c3aed", "#d97706", "#0284c7"]
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

        // 5. BIỂU ĐỒ 4: TỶ LỆ ĐÁNH GIÁ THEO SẢN PHẨM
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
                            ? ["#1d4ed8", "#059669", "#0284c7", "#ea580c", "#6366f1", "#10b981", "#f59e0b"]
                            : ["#e2e8f0"]
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

        // 6. BIỂU ĐỒ 5: TÌNH TRẠNG PHÂN BỔ TỒN KHO
        const highStock = adminProductsCache.filter(p => p.stockQuantity >= 20).length;
        const normalStock = adminProductsCache.filter(p => p.stockQuantity >= 10 && p.stockQuantity < 20).length;
        const lowStock = adminProductsCache.filter(p => p.stockQuantity > 0 && p.stockQuantity < 10).length;
        const zeroStock = adminProductsCache.filter(p => p.stockQuantity === 0).length;

        const stockCanvas = document.getElementById("stockStatusChart");
        if (stockCanvas && typeof Chart !== "undefined") {
            const ctxStock = stockCanvas.getContext("2d");
            if (stockChartInstance) stockChartInstance.destroy();
            stockChartInstance = new Chart(ctxStock, {
                type: "doughnut",
                data: {
                    labels: ["Dồi dào (≥20)", "Tiêu chuẩn (10-19)", "Sắp hết (1-9)", "Hết hàng (0)"],
                    datasets: [{
                        data: [highStock, normalStock, lowStock, zeroStock],
                        backgroundColor: ["#059669", "#2563eb", "#ea580c", "#dc2626"]
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

        // 7. BẢNG DANH SÁCH PHẢN HỒI THEO THỜI GIAN
        const countEl = document.getElementById("tableCountText");
        if (countEl) countEl.innerText = `Hiển thị ${filteredFeedbacks.length} kết quả`;

        const tbody = document.getElementById("recentReviewsTable");
        if (tbody) {
            if (filteredFeedbacks.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" style="text-align:center; color:var(--text-muted); padding:20px;">
                            Không có đánh giá nào trong khoảng thời gian đã chọn.
                        </td>
                    </tr>
                `;
            } else {
                tbody.innerHTML = filteredFeedbacks.map(f => `
                    <tr>
                        <td><span class="badge badge-info">${formatDateTimeVN(f.createdAt)}</span></td>
                        <td><b>${f.customerName}</b></td>
                        <td>${f.productName}</td>
                        <td>
                            <span class="star-rating-box">
                                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                <span>${f.rating}.0 / 5</span>
                            </span>
                        </td>
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
// 2. QUẢN LÝ SẢN PHẨM & KHO HÀNG (CRUD VIA MODAL)
// =========================================================
async function loadCategoriesAndSuppliers() {
    try {
        categoriesList = await (await fetch(`${API}/categories`)).json();
        suppliersList = await (await fetch(`${API}/suppliers`)).json();

        // Populate filter dropdowns
        const fCat = document.getElementById("fCategory");
        if (fCat) {
            fCat.innerHTML = `<option value="">Tất cả danh mục</option>` +
                categoriesList.map(c => `<option value="${c.categoryId}">${c.categoryName}</option>`).join("");
        }

        const fSup = document.getElementById("fSupplier");
        if (fSup) {
            fSup.innerHTML = `<option value="">Tất cả nhà cung cấp</option>` +
                suppliersList.map(s => `<option value="${s.supplierId}">${s.supplierName}</option>`).join("");
        }

        // Populate modal dropdowns
        const mCat = document.getElementById("mProdCat");
        if (mCat) {
            mCat.innerHTML = categoriesList.map(c => `<option value="${c.categoryId}">${c.categoryName}</option>`).join("");
        }

        const mSup = document.getElementById("mProdSup");
        if (mSup) {
            mSup.innerHTML = suppliersList.map(s => `<option value="${s.supplierId}">${s.supplierName}</option>`).join("");
        }
    } catch (e) {
        console.error("Lỗi loadCategoriesAndSuppliers:", e);
    }
}

async function loadProducts() {
    try {
        const keyword = document.getElementById("fKeyword")?.value.trim() || "";
        const catId = document.getElementById("fCategory")?.value || "";
        const supId = document.getElementById("fSupplier")?.value || "";
        const status = document.getElementById("fStatus")?.value || "";
        const sort = document.getElementById("fSort")?.value || "";

        const params = new URLSearchParams();
        if (keyword) params.append("keyword", keyword);
        if (catId) params.append("categoryId", catId);
        if (supId) params.append("supplierId", supId);
        if (status) params.append("status", status);
        if (sort) params.append("sort", sort);

        const res = await fetch(`${API}/products?${params.toString()}`);
        if (!res.ok) return;
        adminProductsCache = await res.json();

        const countBadge = document.getElementById("productCountBadge");
        if (countBadge) countBadge.innerText = `Đang hiển thị ${adminProductsCache.length} sản phẩm`;

        const tbody = document.getElementById("productTable");
        if (!tbody) return;

        if (adminProductsCache.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9" style="text-align:center; padding:24px; color:var(--text-muted);">
                        Không tìm thấy sản phẩm nào khớp với bộ lọc hiện tại.
                    </td>
                </tr>
            `;
            return;
        }

        tbody.innerHTML = adminProductsCache.map(p => {
            const imgUrl = p.imageUrl || DEFAULT_IMG;
            let stockBadge = "";
            if (p.stockQuantity === 0) {
                stockBadge = `<span class="badge badge-stock-out">Hết hàng (0)</span>`;
            } else if (p.stockQuantity < 10) {
                stockBadge = `<span class="badge badge-stock-low">Sắp hết (${p.stockQuantity} ${p.unit || 'cái'})</span>`;
            } else {
                stockBadge = `<span class="badge badge-stock-high">Còn hàng (${p.stockQuantity} ${p.unit || 'cái'})</span>`;
            }

            return `
                <tr>
                    <td>
                        <img src="${imgUrl}" class="prod-thumb" alt="Product" onerror="this.src='${DEFAULT_IMG}'">
                    </td>
                    <td><span class="badge-tag" style="font-family:monospace; font-weight:700;">${p.productCode}</span></td>
                    <td>
                        <div style="font-weight:700; color:var(--text-primary); font-size:13.5px;">${p.ProductName || p.productName}</div>
                        <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">Trạng thái: <b>${p.status}</b></div>
                    </td>
                    <td><span class="badge badge-info">${p.categoryName || "-"}</span></td>
                    <td>${p.supplierName || "-"}</td>
                    <td style="text-align:right; font-weight:800; color:#1d4ed8; font-size:14px;">
                        ${Number(p.price).toLocaleString("vi-VN")} ₫
                    </td>
                    <td>${stockBadge}</td>
                    <td>
                        <span class="star-rating-box">
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <span>${p.averageRating ? p.averageRating.toFixed(1) : "5.0"}</span>
                            <span style="color:var(--text-muted); font-size:11px;">(${p.totalReviews || 0})</span>
                        </span>
                    </td>
                    <td style="text-align:center;">
                        <div style="display:inline-flex; gap:6px;">
                            <button class="btn" style="padding:5px 10px; font-size:12px;" onclick="openEditProductModal(${p.productId})">Sửa</button>
                            <button class="btn btn-danger" style="padding:5px 10px; font-size:12px;" onclick="deleteProduct(${p.productId})">Xóa</button>
                        </div>
                    </td>
                </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadProducts:", e);
    }
}

function resetProductFilter() {
    document.getElementById("fKeyword").value = "";
    document.getElementById("fCategory").value = "";
    document.getElementById("fSupplier").value = "";
    document.getElementById("fStatus").value = "";
    document.getElementById("fSort").value = "";
    loadProducts();
}

// PRODUCT MODAL HANDLERS
function openAddProductModal() {
    editingProductId = null;
    document.getElementById("productModalTitle").innerText = "Thêm sản phẩm mới vào hệ thống";
    document.getElementById("mProdCode").value = "";
    document.getElementById("mProdName").value = "";
    document.getElementById("mProdPrice").value = "";
    document.getElementById("mProdStock").value = "10";
    document.getElementById("mProdStatus").value = "Đang bán";
    document.getElementById("mProdImage").value = "";
    document.getElementById("modalProdPreviewImg").src = DEFAULT_IMG;

    document.getElementById("productModal").classList.add("show");
}

function openEditProductModal(productId) {
    const p = adminProductsCache.find(x => x.productId === productId);
    if (!p) return;

    editingProductId = p.productId;
    document.getElementById("productModalTitle").innerText = `Chỉnh sửa sản phẩm: ${p.productCode}`;
    document.getElementById("mProdCode").value = p.productCode || "";
    document.getElementById("mProdName").value = p.ProductName || p.productName || "";
    document.getElementById("mProdCat").value = p.categoryId;
    document.getElementById("mProdSup").value = p.supplierId;
    document.getElementById("mProdPrice").value = p.price;
    document.getElementById("mProdStock").value = p.stockQuantity;
    document.getElementById("mProdStatus").value = p.status;
    document.getElementById("mProdImage").value = p.imageUrl || "";
    document.getElementById("modalProdPreviewImg").src = p.imageUrl || DEFAULT_IMG;

    document.getElementById("productModal").classList.add("show");
}

function closeProductModal() {
    document.getElementById("productModal").classList.remove("show");
}

async function saveProductModal() {
    const code = document.getElementById("mProdCode").value.trim();
    const name = document.getElementById("mProdName").value.trim();
    const price = Number(document.getElementById("mProdPrice").value || 0);
    const stock = Number(document.getElementById("mProdStock").value || 0);
    const catId = Number(document.getElementById("mProdCat").value);
    const supId = Number(document.getElementById("mProdSup").value);
    const status = document.getElementById("mProdStatus").value;
    const imageUrl = document.getElementById("mProdImage").value.trim();

    if (!code || !name) {
        return alert("Vui lòng nhập đầy đủ Mã sản phẩm và Tên sản phẩm.");
    }
    if (price <= 0) {
        return alert("Vui lòng nhập giá bán lớn hơn 0 VNĐ.");
    }

    const payload = {
        productCode: code,
        productName: name,
        categoryId: catId,
        supplierId: supId,
        price: price,
        stockQuantity: stock,
        unit: "Cái",
        status: status,
        imageUrl: imageUrl || DEFAULT_IMG
    };

    try {
        let res;
        if (editingProductId) {
            res = await fetch(`${API}/products/${editingProductId}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });
        } else {
            res = await fetch(`${API}/products`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });
        }

        const data = await res.json();
        if (!res.ok) {
            return alert(data.message || "Không thể lưu sản phẩm.");
        }

        alert(data.message || "Lưu thông tin sản phẩm thành công!");
        closeProductModal();
        await refreshAllAdminDataSilently();
        notifyDataChanged("products");
    } catch (err) {
        alert("Lỗi kết nối máy chủ: " + err.message);
    }
}

async function deleteProduct(id) {
    if (!confirm("Xác nhận xóa sản phẩm này khỏi hệ thống?")) return;
    try {
        const res = await fetch(`${API}/products/${id}`, { method: "DELETE" });
        const data = await res.json();
        alert(data.message || "Đã xóa sản phẩm.");
        await refreshAllAdminDataSilently();
        notifyDataChanged("products");
    } catch (err) {
        alert("Lỗi khi xóa: " + err.message);
    }
}

function exportProductsCsv() {
    if (!adminProductsCache || adminProductsCache.length === 0) {
        return alert("Không có dữ liệu sản phẩm để xuất.");
    }
    let csv = "Mã SP,Tên sản phẩm,Danh mục,Nhà cung cấp,Giá bán (VND),Tồn kho,Trạng thái\n";
    adminProductsCache.forEach(p => {
        csv += `"${p.productCode}","${(p.ProductName || p.productName).replace(/"/g, '""')}","${p.categoryName || ''}","${p.supplierName || ''}",${p.price},${p.stockQuantity},"${p.status}"\n`;
    });

    const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", `DS_San_Pham_SGU_${toLocalIsoDate(new Date())}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

// =========================================================
// 3. QUẢN LÝ NHÀ CUNG CẤP (CRUD VIA MODAL)
// =========================================================
async function loadSuppliers() {
    try {
        const keyword = document.getElementById("sSearchKeyword")?.value.trim().toLowerCase() || "";
        const res = await fetch(`${API}/suppliers`);
        if (!res.ok) return;
        suppliersList = await res.json();

        const filtered = suppliersList.filter(s => {
            if (!keyword) return true;
            return (s.supplierCode && s.supplierCode.toLowerCase().includes(keyword)) ||
                   (s.supplierName && s.supplierName.toLowerCase().includes(keyword)) ||
                   (s.address && s.address.toLowerCase().includes(keyword));
        });

        const tbody = document.getElementById("supplierTable");
        if (!tbody) return;

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding:18px; color:var(--text-muted);">Không tìm thấy nhà cung cấp nào.</td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map(s => `
            <tr>
                <td><span class="badge-tag" style="font-family:monospace; font-weight:700;">${s.supplierCode}</span></td>
                <td><b style="color:var(--text-primary);">${s.supplierName}</b></td>
                <td>${s.contactName || "-"}</td>
                <td>${s.phone || "-"}</td>
                <td>${s.email || "-"}</td>
                <td>${s.address || "-"}</td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn" style="padding:4px 9px; font-size:12px;" onclick="openEditSupplierModal(${s.supplierId})">Sửa</button>
                        <button class="btn btn-danger" style="padding:4px 9px; font-size:12px;" onclick="deleteSupplier(${s.supplierId})">Xóa</button>
                    </div>
                </td>
            </tr>
        `).join("");
    } catch (e) {
        console.error("Lỗi loadSuppliers:", e);
    }
}

function openAddSupplierModal() {
    editingSupplierId = null;
    document.getElementById("supplierModalTitle").innerText = "Thêm đối tác nhà cung cấp mới";
    document.getElementById("mSupCode").value = "";
    document.getElementById("mSupName").value = "";
    document.getElementById("mSupContact").value = "";
    document.getElementById("mSupPhone").value = "";
    document.getElementById("mSupEmail").value = "";
    document.getElementById("mSupAddress").value = "";
    document.getElementById("supplierModal").classList.add("show");
}

function openEditSupplierModal(supId) {
    const s = suppliersList.find(x => x.supplierId === supId);
    if (!s) return;
    editingSupplierId = s.supplierId;
    document.getElementById("supplierModalTitle").innerText = `Chỉnh sửa nhà cung cấp: ${s.supplierCode}`;
    document.getElementById("mSupCode").value = s.supplierCode || "";
    document.getElementById("mSupName").value = s.supplierName || "";
    document.getElementById("mSupContact").value = s.contactName || "";
    document.getElementById("mSupPhone").value = s.phone || "";
    document.getElementById("mSupEmail").value = s.email || "";
    document.getElementById("mSupAddress").value = s.address || "";
    document.getElementById("supplierModal").classList.add("show");
}

function closeSupplierModal() {
    document.getElementById("supplierModal").classList.remove("show");
}

async function saveSupplierModal() {
    const code = document.getElementById("mSupCode").value.trim();
    const name = document.getElementById("mSupName").value.trim();
    const phone = document.getElementById("mSupPhone").value.trim();
    const contact = document.getElementById("mSupContact").value.trim();
    const email = document.getElementById("mSupEmail").value.trim();
    const address = document.getElementById("mSupAddress").value.trim();

    if (!code || !name) return alert("Vui lòng nhập Mã và Tên nhà cung cấp.");

    const body = {
        supplierCode: code,
        supplierName: name,
        contactName: contact,
        phone: phone,
        email: email,
        address: address
    };

    try {
        let res;
        if (editingSupplierId) {
            res = await fetch(`${API}/suppliers/${editingSupplierId}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(body)
            });
        } else {
            res = await fetch(`${API}/suppliers`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(body)
            });
        }
        const data = await res.json();
        alert(data.message || "Lưu nhà cung cấp thành công!");
        closeSupplierModal();
        await loadSuppliers();
        await loadCategoriesAndSuppliers();
        notifyDataChanged("suppliers");
    } catch (err) {
        alert("Lỗi lưu nhà cung cấp: " + err.message);
    }
}

async function deleteSupplier(id) {
    if (!confirm("Xác nhận xóa nhà cung cấp này?")) return;
    try {
        const res = await fetch(`${API}/suppliers/${id}`, { method: "DELETE" });
        const data = await res.json();
        alert(data.message || "Đã xóa nhà cung cấp.");
        await loadSuppliers();
        await loadCategoriesAndSuppliers();
        notifyDataChanged("suppliers");
    } catch (err) {
        alert("Lỗi khi xóa nhà cung cấp: " + err.message);
    }
}

// =========================================================
// 4. QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN
// =========================================================
async function loadRoles() {
    try {
        rolesList = await (await fetch(`${API}/roles`)).json();
        const mRole = document.getElementById("mAccRole");
        if (mRole) {
            mRole.innerHTML = rolesList.map(r => `<option value="${r.roleId}">${r.roleName} - ${r.description || ''}</option>`).join("");
        }
    } catch (e) {
        console.error("Lỗi loadRoles:", e);
    }
}

async function loadAccounts() {
    try {
        const res = await fetch(`${API}/accounts`);
        if (!res.ok) return;
        allAccountsCache = await res.json();

        if (document.getElementById("kpiAccounts")) {
            document.getElementById("kpiAccounts").innerText = allAccountsCache.length;
        }

        renderFilteredAccounts();
    } catch (e) {
        console.error("Lỗi loadAccounts:", e);
    }
}

function filterAccountsByRole(role, btn) {
    currentAccountRoleFilter = role;
    document.querySelectorAll("#tabAccounts .filter-toolbar button").forEach(b => b.classList.remove("active"));
    if (btn) btn.classList.add("active");
    renderFilteredAccounts();
}

function renderFilteredAccounts() {
    const tbody = document.getElementById("accountTable");
    if (!tbody) return;

    const filtered = allAccountsCache.filter(a => {
        if (currentAccountRoleFilter === "all") return true;
        return a.roleName === currentAccountRoleFilter;
    });

    if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8" style="text-align:center; padding:18px; color:var(--text-muted);">Không có tài khoản nào thuộc nhóm này.</td></tr>`;
        return;
    }

    tbody.innerHTML = filtered.map(a => {
        let roleBadgeColor = "badge-info";
        if (a.roleName === "Admin") roleBadgeColor = "badge-locked";
        else if (a.roleName === "Manager") roleBadgeColor = "badge-active";

        return `
            <tr>
                <td>#${a.accountId}</td>
                <td>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <div class="user-avatar-circle" style="width:26px; height:26px; font-size:10px; background:#1e293b;">
                            ${(a.username || "U").substring(0, 2).toUpperCase()}
                        </div>
                        <b>${a.username}</b>
                    </div>
                </td>
                <td>${a.fullName}</td>
                <td>${a.email || "-"}</td>
                <td>${a.phone || "-"}</td>
                <td><span class="badge ${roleBadgeColor}">${a.roleName}</span></td>
                <td><span class="badge ${a.isActive ? 'badge-active' : 'badge-locked'}">${a.isActive ? 'Hoạt động' : 'Đã khóa'}</span></td>
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px;">
                        <button class="btn btn-warning" style="padding:4px 9px; font-size:12px;" onclick="toggleAccountLock(${a.accountId})">
                            ${a.isActive ? 'Khóa' : 'Mở khóa'}
                        </button>
                        <button class="btn btn-danger" style="padding:4px 9px; font-size:12px;" onclick="deleteAccount(${a.accountId})">Xóa</button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

function openAddAccountModal() {
    document.getElementById("mAccUser").value = "";
    document.getElementById("mAccFullName").value = "";
    document.getElementById("mAccEmail").value = "";
    document.getElementById("mAccPhone").value = "";
    document.getElementById("accountModal").classList.add("show");
}

function closeAccountModal() {
    document.getElementById("accountModal").classList.remove("show");
}

async function saveAccountModal() {
    const user = document.getElementById("mAccUser").value.trim();
    const name = document.getElementById("mAccFullName").value.trim();
    const email = document.getElementById("mAccEmail").value.trim();
    const phone = document.getElementById("mAccPhone").value.trim();
    const roleId = Number(document.getElementById("mAccRole").value);

    if (!user || !name) return alert("Vui lòng nhập Tên đăng nhập và Họ tên.");

    const body = {
        username: user,
        password: "123456",
        fullName: name,
        email: email,
        phone: phone,
        roleId: roleId
    };

    try {
        const res = await fetch(`${API}/accounts`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        alert(data.message || "Tạo tài khoản thành công!");
        closeAccountModal();
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi tạo tài khoản: " + err.message);
    }
}

async function toggleAccountLock(id) {
    try {
        const res = await fetch(`${API}/accounts/${id}/toggle-status`, { method: "PUT" });
        const data = await res.json();
        alert(data.message || "Đã cập nhật trạng thái tài khoản.");
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi đổi trạng thái tài khoản: " + err.message);
    }
}

async function deleteAccount(id) {
    if (!confirm("Xác nhận xóa tài khoản này khỏi hệ thống?")) return;
    try {
        const res = await fetch(`${API}/accounts/${id}`, { method: "DELETE" });
        const data = await res.json();
        alert(data.message || "Đã xóa tài khoản.");
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi khi xóa tài khoản: " + err.message);
    }
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}
