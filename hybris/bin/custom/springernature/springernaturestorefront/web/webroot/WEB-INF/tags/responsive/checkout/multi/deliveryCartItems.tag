<%@ tag body-content="empty" trimDirectiveWhitespaces="true" %>
<%@ attribute name="cartData" required="true" type="de.hybris.platform.commercefacades.order.data.CartData" %>
<%@ attribute name="showDeliveryAddress" required="true" type="java.lang.Boolean" %>
<%@ attribute name="showPotentialPromotions" required="false" type="java.lang.Boolean" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="template" tagdir="/WEB-INF/tags/responsive/template" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cms" uri="http://hybris.com/tld/cmstags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="theme" tagdir="/WEB-INF/tags/shared/theme" %>
<%@ taglib prefix="format" tagdir="/WEB-INF/tags/shared/format" %>
<%@ taglib prefix="product" tagdir="/WEB-INF/tags/responsive/product" %>
<%@ taglib prefix="grid" tagdir="/WEB-INF/tags/responsive/grid" %>
<%@ taglib prefix="ycommerce" uri="http://hybris.com/tld/ycommercetags" %>
<%@ taglib prefix="common" tagdir="/WEB-INF/tags/responsive/common" %>
<%@ taglib prefix="checkout" tagdir="/WEB-INF/tags/responsive/checkout" %>

<c:set var="hasShippedItems" value="${cartData.deliveryItemsQuantity > 0}" />
<c:set var="deliveryAddress" value="${cartData.deliveryAddress}"/>

<c:if test="${not hasShippedItems}">
	<spring:theme code="checkout.pickup.no.delivery.required"/>
</c:if>

<ul class="checkout-order-summary-list">
<c:if test="${hasShippedItems}">
	<li class="checkout-order-summary-list-heading">
		<c:choose>
			<c:when test="${showDeliveryAddress and not empty deliveryAddress}">
				<div class="title"><spring:theme code="checkout.pickup.items.to.be.shipped" text="Ship To:"/></div>
				<div class="address">
					${fn:escapeXml(deliveryAddress.title)}&nbsp;${fn:escapeXml(deliveryAddress.firstName)}&nbsp;${fn:escapeXml(deliveryAddress.lastName)}
					<br>
					<c:if test="${ not empty deliveryAddress.line1 }">
						${fn:escapeXml(deliveryAddress.line1)},&nbsp;
					</c:if>
					<c:if test="${ not empty deliveryAddress.line2 }">
						${fn:escapeXml(deliveryAddress.line2)},&nbsp;
					</c:if>
					<c:if test="${not empty deliveryAddress.town }">
						${fn:escapeXml(deliveryAddress.town)},&nbsp;
					</c:if>
					<c:if test="${ not empty deliveryAddress.region.name }">
						${fn:escapeXml(deliveryAddress.region.name)},&nbsp;
					</c:if>
					<c:if test="${ not empty deliveryAddress.postalCode }">
						${fn:escapeXml(deliveryAddress.postalCode)},&nbsp;
					</c:if>
					<c:if test="${ not empty deliveryAddress.country.name }">
						${fn:escapeXml(deliveryAddress.country.name)}
					</c:if>
                    <br/>
					<c:if test="${ not empty deliveryAddress.phone }">
						${fn:escapeXml(deliveryAddress.phone)}
					</c:if>
				</div>
			</c:when>
			<c:otherwise>
				<spring:theme code="checkout.pickup.items.to.be.delivered" />
			</c:otherwise>
		</c:choose>
		
	</li>
</c:if>

<c:forEach items="${cartData.entries}" var="entry" varStatus="loop">
	<c:if test="${entry.deliveryPointOfService == null}">
		<c:choose>
			<c:when test="${not empty entry.parameters.returnurl}">
				<c:url value="${entry.parameters.returnurl}" var="productUrl"/>
			</c:when>
			<c:otherwise>
				<c:url value="${entry.product.url}" var="productUrl"/>
			</c:otherwise>
		</c:choose>
		<li class="checkout-order-summary-list-items">
			<div class="thumb">
				<a href="${productUrl}">
					<c:choose>
						<c:when test="${empty entry.parameters.type}">
							<product:productPrimaryImage product="${entry.product}" format="thumbnail"/>
						</c:when>
						<c:otherwise>
							<checkout:entryImage entry="${entry}"/>
						</c:otherwise>
					</c:choose>
				</a>
			</div>
			<div class="price"><format:price priceData="${entry.totalPrice}" displayFreeForZero="true"/></div>
			<div class="details">
				<div class="name"><a href="${productUrl}">${fn:escapeXml(entry.product.name)}</a></div>
				<c:forEach var="keyValue" items="${entry.parameters}">
					<div class="qty">${fn:toUpperCase(keyValue.key)}: ${keyValue.value}</div>
				</c:forEach>
				<div>
                    <span class="label-spacing"><spring:theme code="order.itemPrice" />:</span>
					<c:if test="${entry.product.multidimensional}">
						<%-- if product is multidimensional with different prices, show range, else, show unique price --%>
						<c:choose>
							<c:when test="${entry.product.priceRange.minPrice.value ne entry.product.priceRange.maxPrice.value}">
								<format:price priceData="${entry.product.priceRange.minPrice}" /> - <format:price priceData="${entry.product.priceRange.maxPrice}" />
							</c:when>
                            <c:when test="${entry.product.priceRange.minPrice.value eq entry.product.priceRange.maxPrice.value}">
                                <format:price priceData="${entry.product.priceRange.minPrice}" />
                            </c:when>
							<c:otherwise>
								<format:price priceData="${entry.product.price}" />
							</c:otherwise>
						</c:choose>
					</c:if>
					<c:if test="${! entry.product.multidimensional}">
						<format:price priceData="${entry.basePrice}" displayFreeForZero="true" />
					</c:if>
				</div>
				<div class="qty"><span><spring:theme code="basket.page.qty"/>:</span>${entry.quantity}</div>
				<div>
					<c:forEach items="${entry.product.baseOptions}" var="option">
						<c:if test="${not empty option.selected and option.selected.url eq entry.product.url}">
							<c:forEach items="${option.selected.variantOptionQualifiers}" var="selectedOption">
								<div>${selectedOption.name}: ${selectedOption.value}</div>
							</c:forEach>
						</c:if>
					</c:forEach>
					
					<c:if test="${ycommerce:doesPotentialPromotionExistForOrderEntry(cartData, entry.entryNumber) && showPotentialPromotions}">
                        <c:forEach items="${cartData.potentialProductPromotions}" var="promotion">
                            <c:set var="displayed" value="false"/>
                            <c:forEach items="${promotion.consumedEntries}" var="consumedEntry">
                                <c:if test="${not displayed && consumedEntry.orderEntryNumber == entry.entryNumber}">
                                    <c:set var="displayed" value="true"/>
                                    <span class="promotion">${promotion.description}</span>
                                </c:if>
                            </c:forEach>
                        </c:forEach>
					</c:if>
					
					<c:if test="${ycommerce:doesAppliedPromotionExistForOrderEntry(cartData, entry.entryNumber)}">
                        <c:forEach items="${cartData.appliedProductPromotions}" var="promotion">
                            <c:set var="displayed" value="false"/>
                            <c:forEach items="${promotion.consumedEntries}" var="consumedEntry">
                                <c:if test="${not displayed && consumedEntry.orderEntryNumber == entry.entryNumber}">
                                    <c:set var="displayed" value="true"/>
                                    <span class="promotion">${promotion.description}</span>
                                </c:if>
                            </c:forEach>
                        </c:forEach>
					</c:if>
					<common:configurationInfos entry="${entry}"/>
				</div>
				<c:if test="${entry.product.multidimensional}" >
					<a href="#" id="QuantityProductToggle" data-index="${loop.index}" class="showQuantityProductOverlay updateQuantityProduct-toggle">
						<span><spring:theme code="order.product.seeDetails"/></span>
					</a>
				</c:if>
				
				<spring:url value="/checkout/multi/getReadOnlyProductVariantMatrix" var="targetUrl"/>
				<grid:gridWrapper entry="${entry}" index="${loop.index}" styleClass="display-none"
					targetUrl="${targetUrl}"/>
			</div>
		</li>
	</c:if>
</c:forEach>

</ul>
