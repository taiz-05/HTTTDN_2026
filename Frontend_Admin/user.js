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
    if (target) {
        target.style.display = "block";
        target.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    if (btn) btn.classList.add("active");

    if (sectionId === "secSurveys") {
        setTimeout(loadMySurveys, 30);
    } else if (sectionId === "secFeedback") {
        setTimeout(() => loadCommunityFeedbacks(false), 30);
    } else if (sectionId === "secProfile") {
        setTimeout(refreshProfileData, 30);
    }
}

async function refreshProfileData() {
    if (!currentCus) return;
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
        if (document.getElementById("profCardAgeTag")) document.getElementById("profCardAgeTag").innerText = (prof.age || 20) + " tuổi";
    } catch (e) {
        console.error("Lỗi refreshProfileData:", e);
    }
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
        if (document.getElementById("profCardAgeTag")) document.getElementById("profCardAgeTag").innerText = (prof.age || 20) + " tuổi";
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

        const myFeedbacks = allFeedbacksCache.filter(f => f.accountId === currentCus.accountId);
        if (document.getElementById("profStatReviews")) {
            document.getElementById("profStatReviews").innerText = myFeedbacks.length;
        }

        const myCompletedSurveys = allSurveysCache.filter(s => s.isCompleted);
        if (document.getElementById("profStatSurveys")) {
            document.getElementById("profStatSurveys").innerText = myCompletedSurveys.length;
        }

        if (document.getElementById("reviewModal")?.classList.contains("show") && selectedModalProductId) {
            await loadModalProductReviews(selectedModalProductId);
        }
    } catch (err) {
        console.error("Lỗi refreshCustomerDataSilently:", err);
    }
}

// =========================================================
// 1. GỬI PHẢN HỒI VỀ SẢN PHẨM & DANH MỤC SẢN PHẨM
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

        const directSelect = document.getElementById("directFbProduct");
        if (directSelect) {
            const curVal = directSelect.value;
            directSelect.innerHTML = allProductsCache.map(p =>
                `<option value="${p.productId}">${p.productName} (${Number(p.price).toLocaleString("vi-VN")} ₫)</option>`
            ).join("");
            if (curVal) directSelect.value = curVal;
        }

        filterShowcaseProducts();
    } catch (e) {
        console.error("Lỗi loadProductShowcase:", e);
    }
}

async function submitDirectFeedback() {
    const productId = Number(document.getElementById("directFbProduct")?.value || 0);
    const rating = Number(document.getElementById("directFbRating")?.value || 5);
    const comment = (document.getElementById("directFbComment")?.value || "").trim();

    if (!productId) return alert("Vui lòng chọn sản phẩm cần phản hồi!");
    if (!comment) return alert("Vui lòng nhập nội dung phản hồi về sản phẩm!");

    try {
        const res = await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ productId, rating, comment })
        });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Lỗi gửi phản hồi.");

        alert(data.message || "Đã gửi phản hồi về sản phẩm thành công!");
        document.getElementById("directFbComment").value = "";
        await refreshCustomerDataSilently();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi kết nối khi gửi phản hồi: " + err.message);
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
                        <span style="font-size:11.5px; color:var(--text-muted);">(${p.reviewCount ?? p.totalReviews ?? 0} phản hồi)</span>
                    </div>
                </div>
                <button class="btn btn-primary" style="width:100%; padding:9px; font-size:13px; display:inline-flex; align-items:center; justify-content:center; gap:6px;" onclick="openReviewModal(${p.productId})">
                    <span>Gửi phản hồi về sản phẩm</span>
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
    document.getElementById("modalProdName").innerText = prod.ProductName || prod.productName;
    document.getElementById("modalProdPrice").innerText = Number(prod.price).toLocaleString("vi-VN") + " ₫";
    document.getElementById("modalFbComment").value = "";

    selectStar(5);
    document.getElementById("reviewModal").classList.add("show");

    await loadModalProductReviews(prod.productId);
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
            box.innerHTML = `<p style="font-size:13px; color:var(--text-muted); padding:10px 0;">Chưa có phản hồi nào cho sản phẩm này.</p>`;
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
                        <span style="font-weight:700; font-size:11.5px; text-transform:uppercase; letter-spacing:0.04em;">✓ Phản hồi từ Người quản lý:</span>
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
    if (!comment) return alert("Vui lòng nhập nội dung phản hồi của bạn.");

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
        alert(data.message || "Đã gửi phản hồi về sản phẩm thành công!");

        document.getElementById("modalFbComment").value = "";
        closeReviewModal();
        await refreshCustomerDataSilently();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi gửi phản hồi: " + err.message);
    }
}

// BỘ LỌC ĐÁNH GIÁ THÔNG MINH (ENTERPRISE FILTER SUITE)
let reviewFilterCategory = "";
let reviewFilterRating = null;
let reviewFilterRepliedOnly = false;

async function loadCommunityFeedbacks(resetFilter = false) {
    try {
        if (resetFilter) {
            reviewFilterCategory = "";
            reviewFilterRating = null;
            reviewFilterRepliedOnly = false;
            const searchEl = document.getElementById("reviewSearchInput");
            if (searchEl) searchEl.value = "";
            document.querySelectorAll(".review-filter-toolbar .filter-pill").forEach(p => p.classList.remove("active"));
            const pillAll = document.getElementById("pillReviewCatAll");
            if (pillAll) pillAll.classList.add("active");
        }

        const res = await fetch(`${CUS_API}/all-feedbacks`);
        allFeedbacksCache = await res.json();
        renderFilteredCommunityFeedbacks();
    } catch (e) {
        console.error("Lỗi loadCommunityFeedbacks:", e);
    }
}

function filterReviewByCategory(cat, btn) {
    reviewFilterCategory = cat;
    document.querySelectorAll(".review-filter-toolbar .filter-pill").forEach(p => {
        if (p.id !== "pillReview5Star" && p.id !== "pillReviewReplied") p.classList.remove("active");
    });
    if (btn) btn.classList.add("active");
    renderFilteredCommunityFeedbacks();
}

function filterReviewByRating(stars, btn) {
    if (reviewFilterRating === stars) {
        reviewFilterRating = null;
        if (btn) btn.classList.remove("active");
    } else {
        reviewFilterRating = stars;
        if (btn) btn.classList.add("active");
    }
    renderFilteredCommunityFeedbacks();
}

function filterReviewByReplied(btn) {
    reviewFilterRepliedOnly = !reviewFilterRepliedOnly;
    if (btn) btn.classList.toggle("active", reviewFilterRepliedOnly);
    renderFilteredCommunityFeedbacks();
}

function filterCommunityReviewsLive() {
    renderFilteredCommunityFeedbacks();
}

function resetReviewFilters() {
    loadCommunityFeedbacks(true);
}

function renderFilteredCommunityFeedbacks() {
    const tbody = document.getElementById("myFeedbackTable");
    if (!tbody) return;

    const kw = (document.getElementById("reviewSearchInput")?.value || "").trim().toLowerCase();

    const filtered = allFeedbacksCache.filter(f => {
        // Lọc theo danh mục sản phẩm
        if (reviewFilterCategory) {
            const prod = allProductsCache.find(p => p.productId === f.productId);
            const cat = ((prod && prod.categoryName) || f.categoryName || f.productName || "").toLowerCase();
            if (!cat.includes(reviewFilterCategory.toLowerCase())) return false;
        }

        // Lọc theo số sao
        if (reviewFilterRating !== null && f.rating !== reviewFilterRating) {
            return false;
        }

        // Lọc chỉ xem phản hồi đã có câu trả lời từ Quản lý
        if (reviewFilterRepliedOnly && !f.adminReply) {
            return false;
        }

        // Lọc theo từ khóa tìm kiếm
        if (kw) {
            const matchName = f.productName && f.productName.toLowerCase().includes(kw);
            const matchUser = f.customerName && f.customerName.toLowerCase().includes(kw);
            const matchComment = f.comment && f.comment.toLowerCase().includes(kw);
            const matchReply = f.adminReply && f.adminReply.toLowerCase().includes(kw);
            if (!matchName && !matchUser && !matchComment && !matchReply) return false;
        }

        return true;
    });

    const countBadge = document.getElementById("reviewFilterCountBadge");
    if (countBadge) {
        countBadge.innerText = `Đang hiển thị ${filtered.length} / ${allFeedbacksCache.length} phản hồi`;
    }

    if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:28px; color:var(--text-muted); font-size:13px;">Không tìm thấy phản hồi nào phù hợp tiêu chí lọc.</td></tr>`;
        return;
    }

    tbody.innerHTML = filtered.map(f => {
        const isMine = f.accountId === currentCus.accountId;
        return `
        <tr>
            <td><img src="${f.productImage || DEFAULT_IMG}" class="prod-thumb" alt="${f.productName}" onerror="this.src='${DEFAULT_IMG}'"></td>
            <td><b style="color:var(--text-primary); font-size:13.5px;">${f.productName}</b></td>
            <td>
                <div style="font-weight:700; color:#0F172A;">${f.customerName}</div>
                ${isMine ? '<span class="badge badge-customer" style="margin-top:2px; font-size:10px; padding:1px 6px;">Của bạn</span>' : ''}
            </td>
            <td>
                <span class="star-rating-box">
                    <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                    <span>${f.rating}.0 / 5</span>
                </span>
            </td>
            <td style="line-height:1.5;">"${f.comment}"</td>
            <td>
                ${f.adminReply ? `
                    <div style="background:#FFF7ED; border-left:3px solid #FF5B00; padding:8px 12px; border-radius:6px; font-size:12.5px; color:#9A3412; line-height:1.5;">
                        <div style="font-weight:800; font-size:11px; text-transform:uppercase; letter-spacing:0.04em; margin-bottom:2px;">✓ Người quản lý CRM giải đáp:</div>
                        <div>${f.adminReply}</div>
                    </div>
                ` : `<span style="color:var(--text-muted); font-size:12px;">Đang chờ bộ phận Quản lý tiếp nhận...</span>`}
            </td>
        </tr>
        `;
    }).join("");
}

// =========================================================
// 2. NHẬN ĐƯỢC KHẢO SÁT VÀ THỰC HIỆN
// =========================================================
async function loadMySurveys() {
    try {
        allSurveysCache = await (await fetch(`${CUS_API}/surveys/${currentCus.accountId}`)).json();

        const totalCount = allSurveysCache.length;
        const doneCount = allSurveysCache.filter(s => s.isCompleted).length;
        const pendingCount = allSurveysCache.filter(s => !s.isCompleted && s.isActive && !s.isExpired).length;

        if (document.getElementById("cusKpiTotalSurveys")) document.getElementById("cusKpiTotalSurveys").innerText = totalCount;
        if (document.getElementById("cusKpiPendingSurveys")) document.getElementById("cusKpiPendingSurveys").innerText = pendingCount;
        if (document.getElementById("cusKpiDoneSurveys")) document.getElementById("cusKpiDoneSurveys").innerText = doneCount;

        const badge = document.getElementById("navSurveyPendingBadge");
        if (badge) {
            if (pendingCount > 0) {
                badge.style.display = "inline-block";
                badge.innerText = `${pendingCount} mới`;
            } else {
                badge.style.display = "none";
            }
        }

        const tbody = document.getElementById("mySurveyTable");
        if (!tbody) return;

        if (allSurveysCache.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:20px; color:var(--text-muted);">Hiện tại chưa có bảng khảo sát nào được gửi đến tài khoản của bạn.</td></tr>`;
            return;
        }

        tbody.innerHTML = allSurveysCache.map(s => {
            let expireLabel = `<span class="badge badge-info">Còn hiệu lực</span>`;
            if (s.expiresAt) {
                const d = new Date(s.expiresAt).toLocaleDateString("vi-VN");
                expireLabel = s.isExpired
                    ? `<span class="badge badge-locked">Đã hết hạn (${d})</span>`
                    : `<span class="badge badge-info">Đến ngày ${d}</span>`;
            }

            let myAnswerHtml = `<span style="color:#d97706; font-size:12px; font-weight:600;">Chưa thực hiện</span>`;
            if (s.isCompleted && s.myResponse) {
                myAnswerHtml = `
                    <div style="font-size:12px; line-height:1.45;">
                        <div><b>Điểm:</b> <span style="color:#1e40af; font-weight:700;">${s.myResponse.score}/5</span> &bull; <b>Ý định:</b> <span class="badge badge-info" style="font-size:10.5px;">${s.myResponse.buyingIntent}</span></div>
                        <div style="color:#475569; margin-top:2px;"><i>"${s.myResponse.customerOpinion}"</i></div>
                    </div>
                `;
            } else if (s.isCompleted) {
                myAnswerHtml = `<span class="badge badge-active">Đã gửi kết quả</span>`;
            }

            let actionHtml = "";
            if (s.isCompleted) {
                actionHtml = `<span class="badge badge-active" style="padding:5px 12px; font-size:12px;">✓ Đã thực hiện</span>`;
            } else if (!s.isActive) {
                actionHtml = `<button class="btn btn-warning" disabled style="padding:4px 10px; font-size:12px;">Đã đóng</button>`;
            } else if (s.isExpired) {
                actionHtml = `<button class="btn btn-warning" disabled style="padding:4px 10px; font-size:12px;">Đã hết hạn</button>`;
            } else {
                actionHtml = `<button class="btn" style="padding:6px 16px; font-size:12px; border-radius:6px;" onclick="openSurveyModal(${s.surveyId})">Thực hiện khảo sát</button>`;
            }

            return `
            <tr>
                <td><b>#${s.surveyId}</b></td>
                <td>
                    <b style="font-size:13.5px; color:var(--text-primary);">${s.title}</b>
                    <div style="color:var(--text-muted); font-size:11.5px; margin-top:2px; line-height:1.4;">${s.description || ""}</div>
                </td>
                <td>
                    <b style="color:#1d4ed8;">${s.targetProduct}</b>
                    <div style="font-size:12px; color:#059669; font-weight:700; margin-top:2px;">${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫</div>
                </td>
                <td>${expireLabel}</td>
                <td>${myAnswerHtml}</td>
                <td style="text-align:center;">${actionHtml}</td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadMySurveys:", e);
    }
}

function selectSurveyScore(val, el) {
    document.getElementById("svSelectedScore").value = val;
    document.querySelectorAll("#svScoreButtonsGroup .survey-score-btn").forEach(b => b.classList.remove("active"));
    if (el) el.classList.add("active");
}

function selectSurveyPriceEval(val, el) {
    document.getElementById("svSelectedPriceEval").value = val;
    document.querySelectorAll(".survey-choice-grid .survey-choice-card").forEach(c => {
        if (c.onclick && c.onclick.toString().includes("selectSurveyPriceEval")) {
            c.classList.remove("active");
        }
    });
    if (el) el.classList.add("active");
}

function toggleSurveyChip(el) {
    if (el) el.classList.toggle("active");
}

function selectSurveyIntent(val, el) {
    document.getElementById("svSelectedIntent").value = val;
    document.querySelectorAll(".survey-choice-grid .survey-choice-card").forEach(c => {
        if (c.onclick && c.onclick.toString().includes("selectSurveyIntent")) {
            c.classList.remove("active");
        }
    });
    if (el) el.classList.add("active");
}

function openSurveyModal(surveyId) {
    const sv = allSurveysCache.find(s => s.surveyId === surveyId);
    if (!sv) return;

    selectedModalSurveyId = sv.surveyId;
    document.getElementById("svModalTitle").innerText = sv.title;
    document.getElementById("svModalDesc").innerText = sv.description || "";
    document.getElementById("svModalProduct").innerText = sv.targetProduct;
    document.getElementById("svModalPrice").innerText = Number(sv.expectedPrice).toLocaleString("vi-VN") + " ₫";
    
    // Đặt lại các giá trị mặc định cho bài khảo sát
    document.getElementById("svSelectedScore").value = 5;
    document.querySelectorAll("#svScoreButtonsGroup .survey-score-btn").forEach((b, idx) => {
        b.classList.toggle("active", idx === 4);
    });

    document.getElementById("svSelectedPriceEval").value = "Giá rất hợp lý / Đáng đầu tư";
    const priceCards = document.querySelectorAll(".survey-choice-grid .survey-choice-card");
    priceCards.forEach((c, idx) => {
        if (c.onclick && c.onclick.toString().includes("selectSurveyPriceEval")) {
            c.classList.toggle("active", idx === 0);
        }
    });

    document.getElementById("svSelectedIntent").value = "Đặt trước ngay đợt đầu (Pre-order)";
    priceCards.forEach((c, idx) => {
        if (c.onclick && c.onclick.toString().includes("selectSurveyIntent")) {
            c.classList.toggle("active", idx === 4);
        }
    });

    if (document.getElementById("svModalWillingPrice")) {
        document.getElementById("svModalWillingPrice").value = Number(sv.expectedPrice).toLocaleString("vi-VN") + " ₫";
    }
    document.getElementById("svModalOpinion").value = "";

    document.getElementById("surveyModal").classList.add("show");
}

function closeSurveyModal() {
    document.getElementById("surveyModal").classList.remove("show");
}

async function submitModalSurvey() {
    const score = Number(document.getElementById("svSelectedScore")?.value || 5);
    const intent = document.getElementById("svSelectedIntent")?.value || "Đặt trước ngay đợt đầu (Pre-order)";
    const priceEval = document.getElementById("svSelectedPriceEval")?.value || "Giá rất hợp lý / Đáng đầu tư";
    
    const selectedChips = Array.from(document.querySelectorAll("#svChipsGroup .survey-chip-item.active"))
        .map(c => c.getAttribute("data-val") || c.innerText.replace("✓", "").trim())
        .filter(Boolean);
    const chipText = selectedChips.length > 0 ? selectedChips.join(", ") : "Hiệu năng vượt trội, Pin trâu";

    const willingPrice = document.getElementById("svModalWillingPrice")?.value.trim() || "";
    const extraOpinion = document.getElementById("svModalOpinion")?.value.trim() || "";

    // Đóng gói cấu trúc phản hồi chi tiết đa tiêu chí
    let formattedOpinion = `[Đánh giá giá: ${priceEval}] [Tiêu chí mong đợi: ${chipText}]`;
    if (willingPrice) formattedOpinion += ` [Giá sẵn sàng chi: ${willingPrice}]`;
    if (extraOpinion) formattedOpinion += ` [Góp ý: ${extraOpinion}]`;

    try {
        const res = await fetch(`${CUS_API}/surveys/${selectedModalSurveyId}/submit/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                score,
                buyingIntent: intent,
                customerOpinion: formattedOpinion
            })
        });
        const data = await res.json();
        alert(data.message || "Đã gửi bảng khảo sát thành công! Cảm ơn ý kiến quý báu của bạn.");
        closeSurveyModal();
        await loadMySurveys();
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi gửi khảo sát: " + err.message);
    }
}

// =========================================================
// 3. CHỈNH SỬA THÔNG TIN CÁ NHÂN
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
        alert(data.message || "Đã lưu chỉnh sửa thông tin cá nhân thành công!");

        currentCus.fullName = fullName;
        localStorage.setItem("currentCustomer", JSON.stringify(currentCus));

        const initials = getInitials(fullName);
        if (document.getElementById("cusAvatarTop")) document.getElementById("cusAvatarTop").innerText = initials;
        if (document.getElementById("profAvatarBig")) document.getElementById("profAvatarBig").innerText = initials;
        if (document.getElementById("cusWelcome")) document.getElementById("cusWelcome").innerText = fullName;
        if (document.getElementById("profCardFullName")) document.getElementById("profCardFullName").innerText = fullName;
        if (document.getElementById("profCardInterestTag")) document.getElementById("profCardInterestTag").innerText = interest;
        if (document.getElementById("profCardAgeTag")) document.getElementById("profCardAgeTag").innerText = age + " tuổi";

        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi khi cập nhật thông tin: " + err.message);
    }
}

function logoutCustomer() {
    localStorage.removeItem("currentCustomer");
    window.location.href = "customer_login.html";
}
