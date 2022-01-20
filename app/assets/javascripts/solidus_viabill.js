let viabillBtn;
let viabillCheckoutBody;
let viabillDiv;
let viabillPaymentForm;
let frontend;
let paymentMethodId;

const fetchCheckoutAuthorizeBody = () => {
  return fetch('/checkout_authorize?payment_method_id=' + paymentMethodId, {
    method: 'GET'
  });
}

const createForm = () => {
  viabillDiv = document.getElementById('viabill-payment');
  // create form
  viabillPaymentForm = document.createElement('form');
  viabillPaymentForm.id = 'viabill-payments-form';
  viabillPaymentForm.action = 'https://secure.viabill.com/api/checkout-authorize/addon/merchant-direct';
  viabillPaymentForm.method = 'POST';
  //create and append form elements
  Object.keys(viabillCheckoutBody).forEach((key) => createAndAppendElement(key, viabillPaymentForm, false));
  //append form to base element
  viabillDiv.appendChild(viabillPaymentForm);
}

const createAndAppendElement = (key, form, custom) => {
  if (key == 'customParams') {
    Object.keys(viabillCheckoutBody[key]).forEach((customKey) => createAndAppendElement(customKey, form, true));
  }
  else {
    const value = viabillCheckoutBody[key];
    const ele = document.createElement('input');
    ele.type = 'hidden';
    if (custom == true) ele.name = 'customParams[' + key + ']';
    else ele.name = key;
    ele.value = value;
    form.appendChild(ele);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  viabillBtn = document.getElementById('viabill-button');

  if (viabillBtn) {
    frontend = viabillBtn.dataset.frontend;

    if (frontend) {
      paymentMethodId = document.querySelector('[name="order[payments_attributes][][payment_method_id]"]:checked').value
    } else {
      paymentMethodId = document.querySelector('[name="payment[payment_method_id]"]:checked').value
    }

    viabillBtn.addEventListener('click', (e) => {
      e.preventDefault();

      fetchCheckoutAuthorizeBody()
      .then((resp) => resp.json())
      .then((response) => response.body)
      .then((body) => viabillCheckoutBody = body)
      .then(() => createForm())
      .then(() => viabillPaymentForm.submit())
    });
  }
});
