const CUS_API = "http://localhost:5000/api/customer";
const PROD_API = "http://localhost:5000/api/admin/products";
const DEFAULT_IMG = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500";

let currentCus = null;
let allProductsCache = [];
let allSurveysCache = [];
let selectedModalProductId = null;
let selectedModalStar = 5;
let selectedModalSurveyId = null;

const syncChannel = new BroadcastChannel("htttdn_realtime_sync");

function notifyDataChanged(scope) {
    const payload = { scope, timestamp: Date.now() };
    syncChannel.postMessage(payload);
    localStorage.setItem("htttdn_sync_event", JSON.stringify(payload));
}

syncChannel.onmessage = () => refreshCustomerDataSilently();
window.addEventListener("storage", (e) => {
    if (e.key === "htttdn_sync_event") refreshCustomerDataSilently();
});
window.addEventListener("focus", () => refreshCustomerDataSilently());

window.onload = () => {
    currentCus = JSON.parse(localStorage.getItem("currentCustomer") || "null");
    if (!currentCus) {
        window.location.href = "customer_login.html";
        return;
    }
    initCustomerPortal();
    setInterval(refreshCustomerDataSilently, 4000);
};

function switchCustomerTab(sectionId, btn) {
    document.querySelectorAll(".cus-section").forEach(sec => sec.style.display = "none");
    document.querySelectorAll(".cus-nav-btn").forEach(b => b.classList.remove("active"));
    document.getElementById(sectionId).style.display = "block";
    if (btn) btn.classList.add("active");
}

async function initCustomerPortal() {
    document.getElementById("cusWelcome").innerText = "Khách hàng: " + currentCus.fullName;

    const prof = await (await fetch(`${CUS_API}/profile/${currentCus.accountId}`)).json();
    document.getElementById("pFullName").value = prof.fullName;
    document.getElementById("pPhone").value = prof.phone || "";
    document.getElementById("pAge").value = prof.age;
    document.getElementById("pAddress").value = prof.address || "";
    document.getElementById("pInterest").value = prof.interest || "Gaming";

    await refreshCustomerDataSilently();
}

async function refreshCustomerDataSilently() {
    if (!currentCus) return;
    await Promise.all([
        loadProductShowcase(),
        loadCommunityFeedbacks(false),
        loadMySurveys()
    ]);

    // Nếu đang mở Pop-up đánh giá của 1 sản phẩm thì làm mới luôn danh sách nhận xét bên trong Pop-up
    if (document.getElementById("reviewModal").classList.contains("show") && selectedModalProductId) {
        await loadModalProductReviews(selectedModalProductId);
    }
}

async function loadProductShowcase() {
    allProductsCache = await (await fetch(PROD_API)).json();

    const filterSelect = document.getElementById("filterReviewProduct");
    const currentSelected = filterSelect.value;
    filterSelect.innerHTML = `<option value="">Tất cả sản phẩm</option>` +
        allProductsCache.map(p => `<option value="${p.productId}">${p.productName}</option>`).join("");
    filterSelect.value = currentSelected;

    filterShowcaseProducts();
}

function filterShowcaseProducts() {
    const kw = (document.getElementById("cusSearchInput")?.value || "").trim().toLowerCase();
    const filtered = allProductsCache.filter(p =>
        p.productName.toLowerCase().includes(kw) ||
        (p.categoryName && p.categoryName.toLowerCase().includes(kw))
    );
    renderProductCards(filtered);
}

function renderProductCards(list) {
    document.getElementById("productGallery").innerHTML = list.map(p => {
        const statusBadge = p.status === "Đang bán"
            ? `<span class="badge badge-active">${p.status}</span>`
            : `<span class="badge badge-locked">${p.status}</span>`;

        return `
        <div class="product-card">
            <img src="${p.imageUrl || DEFAULT_IMG}" alt="${p.productName}" onerror="this.src='${DEFAULT_IMG}'">
            <div class="product-card-body">
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <span class="badge badge-info">${p.categoryName}</span>
                        ${statusBadge}
                    </div>
                    <div class="product-card-title">${p.productName}</div>
                    <div class="product-card-price">${Number(p.price).toLocaleString()} đ</div>
                    <div style="font-size:12.5px; color:var(--text-muted); margin-bottom:12px;">
                        Điểm TB: <b style="color:#d97706;">${Number(p.avgRating ?? 5).toFixed(1)}/5.0</b> (${p.reviewCount ?? 0} đánh giá)
                    </div>
                </div>
                <button class="btn btn-success" style="width:100%;" onclick="openReviewModal(${p.productId})">
                    Đánh giá & Xem nhận xét
                </button>
            </div>
        </div>
        `;
    }).join("");
}

async function openReviewModal(productId) {
    const prod = allProductsCache.find(p => p.productId === productId) || allProductsCache[0];
    if (!prod) return;

    selectedModalProductId = prod.productId;
    document.getElementById("modalProdImg").src = prod.imageUrl || DEFAULT_IMG;
    document.getElementById("modalProdCat").innerText = prod.categoryName || "Sản phẩm";
    document.getElementById("modalProdName").innerText = prod.productName;
    document.getElementById("modalProdPrice").innerText = Number(prod.price).toLocaleString() + " đ";
    document.getElementById("modalFbComment").value = "";

    selectStar(5);
    document.getElementById("reviewModal").classList.add("show");

    await loadModalProductReviews(prod.productId);
}

function openReviewModalFromFilter() {
    const chosenId = Number(document.getElementById("filterReviewProduct").value);
    const targetId = chosenId > 0 ? chosenId : (allProductsCache[0]?.productId || 1);
    openReviewModal(targetId);
}

function closeReviewModal() {
    document.getElementById("reviewModal").classList.remove("show");
}

function selectStar(star) {
    selectedModalStar = star;
    const labels = {
        5: "5/5 - Rất hài lòng",
        4: "4/5 - Hài lòng",
        3: "3/5 - Bình thường",
        2: "2/5 - Chưa tốt",
        1: "1/5 - Không hài lòng"
    };
    document.getElementById("starTextLabel").innerText = labels[star];

    const stars = document.querySelectorAll("#reviewModal .star-btn");
    stars.forEach((btn, idx) => {
        btn.classList.toggle("active", idx < star);
    });
}

async function loadModalProductReviews(productId) {
    const list = await (await fetch(`${CUS_API}/all-feedbacks?productId=${productId}`)).json();
    document.getElementById("modalReviewCount").innerText = list.length;

    const box = document.getElementById("modalProductReviewsBox");
    if (list.length === 0) {
        box.innerHTML = `<p style="font-size:13px; color:var(--text-muted);">Chưa có đánh giá nào cho sản phẩm này.</p>`;
        return;
    }

    box.innerHTML = list.map(f => `
        <div class="review-item-card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <b>${f.customerName} ${f.accountId === currentCus.accountId ? '<span class="badge badge-active">Của bạn</span>' : ''}</b>
                <span style="color:#d97706; font-weight:700;">${f.rating} / 5 sao</span>
            </div>
            <div style="margin-top:4px; font-size:13px;">${f.comment}</div>
            ${f.adminReply ? `<div class="review-reply-box"><b>Phản hồi từ Quản lý:</b> ${f.adminReply}</div>` : ''}
        </div>
    `).join("");
}

async function submitModalFeedback() {
    const comment = document.getElementById("modalFbComment").value.trim();
    if (!comment) return alert("Vui lòng nhập nội dung nhận xét.");

    const body = {
        productId: selectedModalProductId,
        rating: selectedModalStar,
        comment
    };

    const res = await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    const data = await res.json();
    alert(data.message || "Đã gửi phản hồi thành công.");

    document.getElementById("modalFbComment").value = "";
    await refreshCustomerDataSilently();
    notifyDataChanged("feedbacks");
}

async function loadCommunityFeedbacks(resetFilter = false) {
    const filterEl = document.getElementById("filterReviewProduct");
    if (resetFilter && filterEl) filterEl.value = "";
    const prodId = filterEl ? filterEl.value : "";

    const url = !prodId ? `${CUS_API}/all-feedbacks` : `${CUS_API}/all-feedbacks?productId=${prodId}`;
    const list = await (await fetch(url)).json();

    document.getElementById("myFeedbackTable").innerHTML = list.map(f => {
        const isMine = f.accountId === currentCus.accountId;
        return `
        <tr>
            <td><img src="${f.productImage || DEFAULT_IMG}" class="prod-thumb" alt="${f.productName}" onerror="this.src='${DEFAULT_IMG}'"></td>
            <td><b>${f.productName}</b></td>
            <td><b>${f.customerName}</b> ${isMine ? '<span class="badge badge-active">Của bạn</span>' : ''}</td>
            <td><b>${f.rating} / 5</b></td>
            <td>${f.comment}</td>
            <td>${f.adminReply ? `<span style="color:var(--primary); font-weight:600;">${f.adminReply}</span>` : "<span style='color:#6b7280;'>Chờ phản hồi</span>"}</td>
        </tr>
        `;
    }).join("");
}

async function loadMySurveys() {
    allSurveysCache = await (await fetch(`${CUS_API}/surveys/${currentCus.accountId}`)).json();
    document.getElementById("mySurveyTable").innerHTML = allSurveysCache.map(s => {
        let expireLabel = `<span class="badge badge-info">Không thời hạn</span>`;
        if (s.expiresAt) {
            const d = new Date(s.expiresAt).toLocaleDateString("vi-VN");
            expireLabel = s.isExpired
                ? `<span class="badge badge-locked">Hết hạn (${d})</span>`
                : `<span class="badge badge-info">Đến ${d}</span>`;
        }

        let actionHtml = "";
        if (s.isCompleted) {
            actionHtml = `<span class="badge badge-active">Đã thực hiện</span>`;
        } else if (!s.isActive) {
            actionHtml = `<button class="btn btn-warning" disabled>Khảo sát đang khóa</button>`;
        } else if (s.isExpired) {
            actionHtml = `<button class="btn btn-warning" disabled>Đã hết hạn</button>`;
        } else {
            actionHtml = `<button class="btn btn-success" onclick="openSurveyModal(${s.surveyId})">Thực hiện khảo sát</button>`;
        }

        return `
        <tr>
            <td><b>${s.title}</b><br><small style="color:var(--text-muted);">${s.description || ""}</small></td>
            <td><b>${s.targetProduct}</b></td>
            <td><b>${Number(s.expectedPrice).toLocaleString()} đ</b></td>
            <td>${expireLabel}</td>
            <td>${actionHtml}</td>
        </tr>
        `;
    }).join("");
}

function openSurveyModal(surveyId) {
    const sv = allSurveysCache.find(s => s.surveyId === surveyId);
    if (!sv) return;

    selectedModalSurveyId = sv.surveyId;
    document.getElementById("svModalTitle").innerText = sv.title;
    document.getElementById("svModalDesc").innerText = sv.description || "";
    document.getElementById("svModalProduct").innerText = sv.targetProduct;
    document.getElementById("svModalPrice").innerText = Number(sv.expectedPrice).toLocaleString() + " đ";
    document.getElementById("svModalOpinion").value = "";

    document.getElementById("surveyModal").classList.add("show");
}

function closeSurveyModal() {
    document.getElementById("surveyModal").classList.remove("show");
}

async function submitModalSurvey() {
    const score = Number(document.getElementById("svModalScore").value);
    const buyingIntent = document.getElementById("svModalIntent").value;
    const opinion = document.getElementById("svModalOpinion").value.trim() || "Mức giá hợp lý.";

    const res = await fetch(`${CUS_API}/surveys/${selectedModalSurveyId}/submit/${currentCus.accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ score, buyingIntent, customerOpinion: opinion })
    });
    const data = await res.json();
    alert(data.message);
    closeSurveyModal();
    await loadMySurveys();
    notifyDataChanged("surveys");
}

async function updateProfile() {
    const body = {
        fullName: document.getElementById("pFullName").value.trim(),
        phone: document.getElementById("pPhone").value.trim(),
        age: Number(document.getElementById("pAge").value),
        address: document.getElementById("pAddress").value.trim(),
        interest: document.getElementById("pInterest").value
    };
    const res = await fetch(`${CUS_API}/profile/${currentCus.accountId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    alert((await res.json()).message);
    notifyDataChanged("customers");
}

function logoutCustomer() {
    localStorage.removeItem("currentCustomer");
    window.location.href = "customer_login.html";
}