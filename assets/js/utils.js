async function createLinkPreview(url, container, layout = "horizontal", width = 380) {
    const target = typeof container === "string" ? document.querySelector(container) : container;
    if (!target) return console.error("Container not found:", container);

    target.innerHTML = `<div style="padding:10px;color:#666;">Loading Product...</div>`;

    try {
        const res = await fetch(`https://api.microlink.io/?url=${encodeURIComponent(url)}`);
        const data = await res.json();
        if (!data || !data.data) throw new Error("No metadata found");

        const meta = data.data;
        const title = (meta.title || "Untitled Product") + " - Grain Vita";
        const description = meta.description || "";
        const image = meta.image?.url || "";
        const hostname = new URL(url).hostname;

        // Layout logic
        const isHorizontal = layout === "horizontal";
        const flexDirection = isHorizontal ? "row" : "column";
        const cardWidth = isHorizontal ? "100%" : `${width}px`;
        const imageStyle = isHorizontal
            ? "flex:0 0 220px; height:220px;"
            : `width:100%; height:220px;`;

        const descriptionHTML = isHorizontal
            ? `<p style="margin:0 0 12px;font-size:14px;color:#555;line-height:1.5;">
                ${description.length > 160 ? description.slice(0, 160) + "..." : description}
              </p>`
            : "";

        target.innerHTML = `
      <div style="
        display:flex;
        flex-direction:${flexDirection};
        border:1px solid #e5e7eb;
        border-radius:12px;
        overflow:hidden;
        max-width:${cardWidth};
        font-family:system-ui, sans-serif;
        box-shadow:0 4px 10px rgba(0,0,0,0.08);
        background:#fff;
        transition:transform 0.2s ease;
      " class="product-card">

        <!-- Product Image -->
        ${image ? `
          <a href="${url}" target="_blank" rel="noopener" style="${imageStyle} display:block; overflow:hidden; position:relative;">
            <img src="${image}" title="${title}" alt="Product Image" style="width:100%; height:100%; object-fit:cover; display:block;">
            <div style="
              position:absolute;
              top:10px;
              left:10px;
              background:#fff;
              border-radius:50%;
              width:36px;
              height:36px;
              display:flex;
              align-items:center;
              justify-content:center;
              box-shadow:0 2px 8px rgba(0,0,0,0.15);
            ">
              <img src="/assets/img/favicon/daraz-ico.png" alt="Daraz" style="width:22px; height:22px; object-fit:contain;">
            </div>
          </a>
        ` : ""}

        <!-- Product Content -->
        <div style="flex:1; padding:12px; display:flex; flex-direction:column; justify-content:space-between;">
          <div>
            <a href="${url}" title="${title}" target="_blank" rel="noopener" style="text-decoration:none; color:inherit;">
              <h4 style="margin:0 0 8px;font-size:18px;font-weight:600;color:#111;">${title}</h4>
            </a>

            ${descriptionHTML}

            <!-- GrainVita Badge -->
            <div style="
              display:inline-flex;
              align-items:center;
              background:#e8f1ff;
              color:#0d6efd;
              border-radius:6px;
              padding:5px 10px;
              font-size:13px;
              font-weight:500;
              margin-bottom:14px;
            ">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 7.99998C16 8.85026 14.981 9.5219 14.7426 10.2891C14.4955 11.0843 14.9335 12.2518 14.4724 12.9137C14.0068 13.5822 12.8057 13.5053 12.1659 13.9919C11.5324 14.4736 11.2337 15.6935 10.4727 15.9517C9.73838 16.2008 8.8138 15.4054 8.00001 15.4054C7.18622 15.4054 6.26164 16.2008 5.52733 15.9517C4.76626 15.6935 4.4676 14.4736 3.83412 13.9919C3.19432 13.5053 1.9932 13.5822 1.52757 12.9137C1.06654 12.2518 1.50451 11.0844 1.25742 10.2892C1.01899 9.52192 0 8.85028 0 8C0 7.14972 1.01899 6.47808 1.25742 5.71084C1.50453 4.91565 1.06656 3.7482 1.52759 3.08632C1.99322 2.41782 3.19432 2.49464 3.83414 2.00814C4.46762 1.52644 4.76628 0.306506 5.52733 0.0483105C6.26164 -0.200807 7.18622 0.594597 8.00001 0.594597C8.8138 0.594597 9.73838 -0.200807 10.4727 0.0483105C11.2338 0.306506 11.5324 1.52644 12.1659 2.00814C12.8057 2.49466 14.0068 2.41783 14.4725 3.08634C14.9335 3.74822 14.4955 4.91567 14.7426 5.71086C14.981 6.47806 16 7.1497 16 7.99998Z" fill="#2A77F2"/>
                <path d="M6.80483 11.9324L3.94727 9.21908L4.98523 8.02564L6.63786 9.59479L10.522 4.61874L11.7181 5.63797L6.80483 11.9324Z" fill="white"/>
              </svg>
              <span style="margin-left: 5px;">Verified Brand Partner</span>
            </div>

            <p style="font-size:13px;color:#888;margin-bottom:10px;">${hostname}</p>
          </div>

          <!-- Buy Button -->
          <div style="text-align:right; margin-top:0px;">
            <a class="btn btn--green"
               href="${url}"
               target="_blank"
               rel="noopener"
               style="
                  display:inline-block;
                  font-size:16px;
                  padding:10px 25px;
                  border-radius:8px;
                  text-decoration:none;
               ">
               Buy Now
            </a>
          </div>
        </div>
      </div>
    `;
    } catch (err) {
        console.error("Link preview error:", err);
        target.innerHTML = `<a href="${url}" target="_blank">${url}</a>`;
    }
}

window.createLinkPreview = createLinkPreview;
