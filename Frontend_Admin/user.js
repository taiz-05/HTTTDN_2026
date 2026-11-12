const CUS_API = "http://localhost:5000/api/customer";
const PROD_API = "http://localhost:5000/api/admin/products";
const DEFAULT_IMG = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500";

let currentCus = null;
let allProductsCache = [];
let allSurveysCache = [];
let allFeedbacksCache = [];
let selectedCategoryFilter = "";
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

function getInitials(fullName) {
    if (!fullName) return "KH";
    const parts = fullName.trim().split(" ");
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

window.onload = () => {
    currentCus = JSON.parse(localStorage.getItem("currentCustomer") || "null");
    if (!currentCus) {
        window.location.href = "customer_login.html";
        return;
    }
    initCustomerPortal();
};

function switchCustomerTab(sectionId, btn) {
    document.querySelectorAll(".cus-section").forEach(sec => sec.style.display = "none");
    document.querySelectorAll(".cus-nav-btn").forEach(b => b.classList.remove("active"));
    const target = document.getElementById(sectionId);
    if (target) target.style.display = "block";
    if (btn) btn.classList.add("active");
}

async function initCustomerPortal() {
    const initials = getInitials(currentCus.fullName);
    if (document.getElementById("cusAvatarTop")) document.getElementById("cusAvatarTop").innerText = initials;
    if (document.getElementById("profAvatarBig")) document.getElementById("profAvatarBig").innerText = initials;
    if (document.getElementById("cusWelcome")) document.getElementById("cusWelcome").innerText = currentCus.fullName;
    if (document.getElementById("profCardFullName")) document.getElementById("profCardFullName").innerText = currentCus.fullName;
    if (document.getElementById("profCardUsername")) document.getElementById("profCardUsername").innerText = "@" + currentCus.username;
    if (document.getElementById("pUsernameDisplay")) document.getElementById("pUsernameDisplay").value = currentCus.username;
    if (document.getElementById("pEmailDisplay")) document.getElementById("pEmailDisplay").value = currentCus.email || (currentCus.username + "@gmail.com");

    try {
        const prof = await (await fetch(`${CUS_API}/profile/${currentCus.accountId}`)).json();
        if (document.getElementById("pFullName")) document.getElementById("pFullName").value = prof.fullName || currentCus.fullName;
        if (document.getElementById("pEmailDisplay") && prof.email) document.getElementById("pEmailDisplay").value = prof.email;
        if (document.getElementById("pPhone")) document.getElementById("pPhone").value = prof.phone || "";
        if (document.getElementById("pAge")) document.getElementById("pAge").value = prof.age || 20;
        if (document.getElementById("pGender")) document.getElementById("pGender").value = prof.gender || "Nam";
        if (document.getElementById("pAddress")) document.getElementById("pAddress").value = prof.address || "";
        if (document.getElementById("pInterest")) document.getElementById("pInterest").value = prof.interest || "Gaming";
        if (document.getElementById("profCardInterestTag")) document.getElementById("profCardInterestTag").innerText = prof.interest || "Gaming";
    } catch (e) {
        console.error("Lỗi nạp hồ sơ khách hàng:", e);
    }

    await refreshCustomerDataSilently();
}

async function refreshCustomerDataSilently() {
    if (!currentCus) return;
    try {
        await Promise.all([
            loadProductShowcase(),
            loadCommunityFeedbacks(false),
            loadMySurveys()
        ]);

        // Cập nhật micro-stats trên Member Card
        const myFeedbacks = allFeedbacksCache.filter(f => f.accountId === currentCus.accountId);
        if (document.getElementById("profStatReviews")) {
            document.getElementById("profStatReviews").innerText = myFeedbacks.length;
        }

        const myCompletedSurveys = allSurveysCache.filter(s => s.isCompleted);
        if (document.getElementById("profStatSurveys")) {
            document.getElementById("profStatSurveys").innerText = myCompletedSurveys.length;
        }

        // Nếu đang mở Pop-up đánh giá thì cập nhật live luôn
        if (document.getElementById("reviewModal")?.classList.contains("show") && selectedModalProductId) {
            await loadModalProductReviews(selectedModalProductId);
        }
    } catch (err) {
        console.error("Lỗi refreshCustomerDataSilently:", err);
    }
}

// =========================================================
// 1. SHOWCASE SẢN PHẨM & BỘ LỌC DANH MỤC
// =========================================================
async function loadProductShowcase() {
    try {
        allProductsCache = await (await fetch(PROD_API)).json();

        const filterSelect = document.getElementById("filterReviewProduct");
        if (filterSelect) {
            const currentSelected = filterSelect.value;
            filterSelect.innerHTML = `<option value="">Tất cả sản phẩm</option>` +
                allProductsCache.map(p => `<option value="${p.productId}">${p.productName}</option>`).join("");
            filterSelect.value = currentSelected;
        }

        filterShowcaseProducts();
    } catch (e) {
        console.error("Lỗi loadProductShowcase:", e);
    }
}

function filterByCategory(catKeyword, btn) {
    selectedCategoryFilter = catKeyword;
    document.querySelectorAll(".cat-pill-btn").forEach(b => b.classList.remove("active"));
    if (btn) btn.classList.add("active");
    filterShowcaseProducts();
}

function filterShowcaseProducts() {
    const kw = (document.getElementById("cusSearchInput")?.value || "").trim().toLowerCase();
    const filtered = allProductsCache.filter(p => {
        if (selectedCategoryFilter) {
            const catName = (p.categoryName || "").toLowerCase();
            if (!catName.includes(selectedCategoryFilter.toLowerCase())) return false;
        }
        if (kw) {
            const nameMatch = p.productName.toLowerCase().includes(kw);
            const catMatch = p.categoryName && p.categoryName.toLowerCase().includes(kw);
            if (!nameMatch && !catMatch) return false;
        }
        return true;
    });
    renderProductCards(filtered);
}

function renderProductCards(list) {
    const gallery = document.getElementById("productGallery");
    if (!gallery) return;

    if (list.length === 0) {
        gallery.innerHTML = `
            <div style="grid-column: 1/-1; text-align:center; padding:40px; background:#ffffff; border:1px solid var(--brand-border); border-radius:var(--radius-lg); color:var(--text-muted);">
                <div style="font-size:32px; margin-bottom:8px;">🔍</div>
                <div style="font-weight:700; font-size:15px; color:var(--text-primary);">Không tìm thấy sản phẩm phù hợp</div>
                <div style="font-size:13px; margin-top:4px;">Vui lòng thử chọn danh mục khác hoặc nhập từ khóa tìm kiếm mới.</div>
            </div>
        `;
        return;
    }

    gallery.innerHTML = list.map(p => {
        let stockBadge = "";
        if (p.stockQuantity === 0) {
            stockBadge = `<span class="badge badge-stock-out">Hết hàng</span>`;
        } else if (p.stockQuantity < 10) {
            stockBadge = `<span class="badge badge-stock-low">Sắp hết (${p.stockQuantity})</span>`;
        } else {
            stockBadge = `<span class="badge badge-stock-high">Còn hàng</span>`;
        }

        return `
        <div class="product-card">
            <img src="${p.imageUrl || DEFAULT_IMG}" alt="${p.productName}" onerror="this.src='${DEFAULT_IMG}'">
            <div class="product-card-body">
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                        <span class="badge badge-info">${p.categoryName || 'Sản phẩm'}</span>
                        ${stockBadge}
                    </div>
                    <div class="product-card-title">${p.ProductName || p.productName}</div>
                    <div class="product-card-price">${Number(p.price).toLocaleString("vi-VN")} ₫</div>
                    <div style="display:flex; align-items:center; gap:5px; margin-bottom:14px;">
                        <span class="star-rating-box">
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <span>${Number(p.avgRating ?? p.averageRating ?? 5).toFixed(1)} / 5</span>
                        </span>
                        <span style="font-size:11.5px; color:var(--text-muted);">(${p.reviewCount ?? p.totalReviews ?? 0} đánh giá)</span>
                    </div>
                </div>
                <button class="btn btn-primary" style="width:100%; padding:9px; font-size:13px; display:inline-flex; align-items:center; justify-content:center; gap:6px;" onclick="openReviewModal(${p.productId})">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                    <span>Đánh giá & Xem nhận xét</span>
                </button>
            </div>
        </div>
        `;
    }).join("");
}

// =========================================================
// 2. GỬI ĐÁNH GIÁ SẢN PHẨM & CỘNG ĐỒNG NHẬN XÉT
// =========================================================
async function openReviewModal(productId) {
    const prod = allProductsCache.find(p => p.productId === productId) || allProductsCache[0];
    if (!prod) return;

    selectedModalProductId = prod.productId;
    document.getElementById("modalProdImg").src = prod.imageUrl || DEFAULT_IMG;
    document.getElementById("modalProdCat").innerText = prod.categoryName || "Sản phẩm";
    document.getElementById("modalProdName").innerText = prod.ProductName || prod.productName;
    document.getElementById("modalProdPrice").innerText = Number(prod.price).toLocaleString("vi-VN") + " ₫";
    document.getElementById("modalFbComment").value = "";

    selectStar(5);
    document.getElementById("reviewModal").classList.add("show");

    await loadModalProductReviews(prod.productId);
}

function openReviewModalFromFilter() {
    const chosenId = Number(document.getElementById("filterReviewProduct")?.value || 0);
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
    try {
        const list = await (await fetch(`${CUS_API}/all-feedbacks?productId=${productId}`)).json();
        document.getElementById("modalReviewCount").innerText = list.length;

        const box = document.getElementById("modalProductReviewsBox");
        if (list.length === 0) {
            box.innerHTML = `<p style="font-size:13px; color:var(--text-muted); padding:10px 0;">Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên nhận xét!</p>`;
            return;
        }

        box.innerHTML = list.map(f => `
            <div class="review-item-card">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <div style="display:flex; align-items:center; gap:6px;">
                        <b style="color:var(--text-primary); font-size:13px;">${f.customerName}</b>
                        ${f.accountId === currentCus.accountId ? '<span class="badge badge-active" style="font-size:10px; padding:1px 6px;">Bạn</span>' : ''}
                    </div>
                    <span class="star-rating-box">
                        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span>${f.rating}.0 / 5</span>
                    </span>
                </div>
                <div style="margin-top:5px; font-size:13px; color:var(--text-secondary); line-height:1.45;">"${f.comment}"</div>
                ${f.adminReply ? `
                    <div class="review-reply-box" style="margin-top:8px;">
                        <span style="font-weight:700; font-size:11.5px; text-transform:uppercase; letter-spacing:0.04em;">✓ Phản hồi từ Quản lý CRM:</span>
                        <div style="margin-top:3px;">${f.adminReply}</div>
                    </div>
                ` : ''}
            </div>
        `).join("");
    } catch (e) {
        console.error("Lỗi loadModalProductReviews:", e);
    }
}

async function submitModalFeedback() {
    const comment = document.getElementById("modalFbComment").value.trim();
    if (!comment) return alert("Vui lòng nhập nội dung nhận xét của bạn.");

    const body = {
        productId: selectedModalProductId,
        rating: selectedModalStar,
        comment
    };

    try {
        const res = await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        alert(data.message || "Đã gửi nhận xét phản hồi thành công!");

        document.getElementById("modalFbComment").value = "";
        closeReviewModal();
        await refreshCustomerDataSilently();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi gửi phản hồi: " + err.message);
    }
}

async function loadCommunityFeedbacks(resetFilter = false) {
    try {
        const filterEl = document.getElementById("filterReviewProduct");
        if (resetFilter && filterEl) filterEl.value = "";
        const prodId = filterEl ? filterEl.value : "";

        const url = !prodId ? `${CUS_API}/all-feedbacks` : `${CUS_API}/all-feedbacks?productId=${prodId}`;
        allFeedbacksCache = await (await fetch(url)).json();

        const tbody = document.getElementById("myFeedbackTable");
        if (!tbody) return;

        if (allFeedbacksCache.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:20px; color:var(--text-muted);">Chưa có đánh giá nào.</td></tr>`;
            return;
        }

        tbody.innerHTML = allFeedbacksCache.map(f => {
            const isMine = f.accountId === currentCus.accountId;
            return `
            <tr>
                <td><img src="${f.productImage || DEFAULT_IMG}" class="prod-thumb" alt="${f.productName}" onerror="this.src='${DEFAULT_IMG}'"></td>
                <td><b style="color:var(--text-primary);">${f.productName}</b></td>
                <td>
                    <b>${f.customerName}</b>
                    ${isMine ? '<span class="badge badge-active" style="margin-left:4px; font-size:10.5px;">Của bạn</span>' : ''}
                </td>
                <td>
                    <span class="star-rating-box">
                        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span>${f.rating}.0 / 5</span>
                    </span>
                </td>
                <td>"${f.comment}"</td>
                <td>
                    ${f.adminReply ? `
                        <div style="background:#eff6ff; border-left:3px solid #2563eb; padding:6px 10px; border-radius:3px; font-size:12.5px; color:#1e3a8a;">
                            <b>Quản lý giải đáp:</b> ${f.adminReply}
                        </div>
                    ` : `<span style="color:var(--text-muted); font-size:12px;">Đang chờ phản hồi...</span>`}
                </td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadCommunityFeedbacks:", e);
    }
}

// =========================================================
// 3. KHẢO SÁT SẢN PHẨM MỚI (MỤC III.4.6 & 4.7)
// =========================================================
async function loadMySurveys() {
    try {
        allSurveysCache = await (await fetch(`${CUS_API}/surveys/${currentCus.accountId}`)).json();
        const tbody = document.getElementById("mySurveyTable");
        if (!tbody) return;

        if (allSurveysCache.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:20px; color:var(--text-muted);">Hiện tại chưa có bài khảo sát nào.</td></tr>`;
            return;
        }

        tbody.innerHTML = allSurveysCache.map(s => {
            let expireLabel = `<span class="badge badge-info">Không thời hạn</span>`;
            if (s.expiresAt) {
                const d = new Date(s.expiresAt).toLocaleDateString("vi-VN");
                expireLabel = s.isExpired
                    ? `<span class="badge badge-locked">Đã hết hạn (${d})</span>`
                    : `<span class="badge badge-info">Đến ngày ${d}</span>`;
            }

            let actionHtml = "";
            if (s.isCompleted) {
                actionHtml = `<span class="badge badge-active" style="padding:5px 12px; font-size:12px;">✓ Đã hoàn tất</span>`;
            } else if (!s.isActive) {
                actionHtml = `<button class="btn btn-warning" disabled style="padding:4px 10px; font-size:12px;">Đang tạm khóa</button>`;
            } else if (s.isExpired) {
                actionHtml = `<button class="btn btn-warning" disabled style="padding:4px 10px; font-size:12px;">Đã hết hạn</button>`;
            } else {
                actionHtml = `<button class="btn btn-success" style="padding:5px 12px; font-size:12px;" onclick="openSurveyModal(${s.surveyId})">Tham gia khảo sát</button>`;
            }

            return `
            <tr>
                <td>
                    <b style="font-size:13.5px; color:var(--text-primary);">${s.title}</b>
                    <div style="color:var(--text-muted); font-size:11.5px; margin-top:2px; line-height:1.4;">${s.description || ""}</div>
                </td>
                <td><b style="color:#1d4ed8;">${s.targetProduct}</b></td>
                <td><b style="color:var(--text-primary); font-size:13.5px;">${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫</b></td>
                <td>${expireLabel}</td>
                <td style="text-align:center;">${actionHtml}</td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadMySurveys:", e);
    }
}

function openSurveyModal(surveyId) {
    const sv = allSurveysCache.find(s => s.surveyId === surveyId);
    if (!sv) return;

    selectedModalSurveyId = sv.surveyId;
    document.getElementById("svModalTitle").innerText = sv.title;
    document.getElementById("svModalDesc").innerText = sv.description || "";
    document.getElementById("svModalProduct").innerText = sv.targetProduct;
    document.getElementById("svModalPrice").innerText = Number(sv.expectedPrice).toLocaleString("vi-VN") + " ₫";
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

    try {
        const res = await fetch(`${CUS_API}/surveys/${selectedModalSurveyId}/submit/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ score, buyingIntent, customerOpinion: opinion })
        });
        const data = await res.json();
        alert(data.message || "Cảm ơn bạn đã đóng góp ý kiến khảo sát!");
        closeSurveyModal();
        await loadMySurveys();
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi gửi khảo sát: " + err.message);
    }
}

// =========================================================
// 4. CẬP NHẬT THÔNG TIN HỒ SƠ CÁ NHÂN (MỤC III.4.5)
// =========================================================
async function updateProfile() {
    const fullName = document.getElementById("pFullName").value.trim();
    const email = document.getElementById("pEmailDisplay")?.value.trim() || "";
    const phone = document.getElementById("pPhone").value.trim();
    const age = Number(document.getElementById("pAge").value || 20);
    const gender = document.getElementById("pGender")?.value || "Nam";
    const address = document.getElementById("pAddress").value.trim();
    const interest = document.getElementById("pInterest").value;

    if (!fullName) return alert("Vui lòng nhập Họ và tên khách hàng.");

    const body = {
        fullName,
        email,
        phone,
        age,
        gender,
        address,
        interest
    };

    try {
        const res = await fetch(`${CUS_API}/profile/${currentCus.accountId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        alert(data.message || "Đã lưu cập nhật thông tin cá nhân thành công!");

        // Cập nhật lại cache và hiển thị UI tức thì
        currentCus.fullName = fullName;
        localStorage.setItem("currentCustomer", JSON.stringify(currentCus));

        const initials = getInitials(fullName);
        if (document.getElementById("cusAvatarTop")) document.getElementById("cusAvatarTop").innerText = initials;
        if (document.getElementById("profAvatarBig")) document.getElementById("profAvatarBig").innerText = initials;
        if (document.getElementById("cusWelcome")) document.getElementById("cusWelcome").innerText = fullName;
        if (document.getElementById("profCardFullName")) document.getElementById("profCardFullName").innerText = fullName;
        if (document.getElementById("profCardInterestTag")) document.getElementById("profCardInterestTag").innerText = interest;

        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi khi cập nhật thông tin: " + err.message);
    }
}

function logoutCustomer() {
    localStorage.removeItem("currentCustomer");
    window.location.href = "customer_login.html";
}
