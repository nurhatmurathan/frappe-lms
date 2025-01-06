<template>
	<div class="">
		<header
			class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
		>
			<Breadcrumbs
				class="h-7"
				:items="[{ label: __('Детали оплаты'), route: { name: 'Billing' } }]"
			/>
		</header>
		<div
			v-if="access.data?.access && orderSummary.data"
			class="pt-5 pb-10 mx-5"
		>
			<!-- <div class="mb-5">
				<div class="text-lg font-semibold">
					{{ __('Адрес') }}
				</div>
			</div> -->
			<div class="flex flex-col justify-between lg:flex-row">
				<div
					class="p-5 mb-10 space-y-4 text-sm font-medium bg-gray-100 rounded-md h-fit lg:order-last lg:mt-10 lg:w-1/4"
				>
					<div class="flex items-center justify-between space-x-2">
						<div class="text-gray-600">
							{{ __('Заказанный товар') }}
						</div>
						<div class="">
							{{ orderSummary.data.title }}
						</div>
					</div>
					<div
						v-if="orderSummary.data.gst_applied"
						class="flex items-center justify-between"
					>
						<div class="text-gray-600">
							{{ __('Первоначальная сумма') }}
						</div>
						<div class="">
							{{ orderSummary.data.original_amount_formatted }}
						</div>
					</div>
					<div
						v-if="orderSummary.data.gst_applied"
						class="flex items-center justify-between mt-2"
					>
						<div class="text-gray-600">
							{{ __('Сумма GST') }}
						</div>
						<div>
							{{ orderSummary.data.gst_amount_formatted }}
						</div>
					</div>
					<div
						class="flex items-center justify-between pt-4 mt-2 border-t border-gray-400"
					>
						<div class="text-lg font-semibold">
							{{ __('Итого') }}
						</div>
						<div class="text-lg font-semibold">
							{{ orderSummary.data.total_amount_formatted }}
						</div>
					</div>
				</div>

				<div class="flex-1 lg:mr-10">
					<div class="mb-5">
						<div class="text-lg font-semibold">
							{{ __('Адрес') }}
						</div>
					</div>
					<div class="grid grid-cols-1 gap-5 md:grid-cols-2">
						<div class="space-y-4">
							<FormControl
								:label="__('Имя для выставления счета')"
								v-model="billingDetails.billing_name"
							/>
							<FormControl
								:label="__('Адресная строка 1')"
								v-model="billingDetails.address_line1"
							/>
							<FormControl
								:label="__('Адресная строка 2')"
								v-model="billingDetails.address_line2"
							/>
							<FormControl :label="__('Город')" v-model="billingDetails.city" />
							<FormControl :label="__('Штат')" v-model="billingDetails.state" />
						</div>
						<div class="space-y-4">
							<Link
								doctype="Country"
								:value="billingDetails.country"
								@change="(option) => changeCurrency(option)"
								:label="__('Страна')"
							/>
							<FormControl
								:label="__('Почтовый индекс')"
								v-model="billingDetails.pincode"
							/>
							<FormControl
								:label="__('Номер телефона')"
								v-model="billingDetails.phone"
							/>
							<Link
								doctype="LMS Source"
								:value="billingDetails.source"
								@change="(option) => (billingDetails.source = option)"
								:label="__('Откуда вы о нас узнали?')"
							/>
							<FormControl
								v-if="billingDetails.country == 'India'"
								:label="__('Номер GST')"
								v-model="billingDetails.gstin"
							/>
							<FormControl
								v-if="billingDetails.country == 'India'"
								:label="__('Номер PAN')"
								v-model="billingDetails.pan"
							/>
						</div>
					</div>
					<div class="flex items-center justify-between pt-4 mt-8 border-t">
						<p class="text-gray-600">
							{{
								__(
									'Убедитесь, что вы ввели правильное имя для выставления счета, так как оно будет использоваться в вашем счете.',
								)
							}}
						</p>
						<Button variant="solid" size="md" @click="generatePaymentLink()">
							{{ __('Перейти к оплате') }}
						</Button>
					</div>
				</div>
			</div>
		</div>
		<div v-else-if="access.data?.message">
			<NotPermitted
				:text="access.data.message"
				:buttonLabel="
					type == 'course' ? 'Просмотреть курсы' : 'Просмотреть группы'
				"
				:buttonLink="type == 'course' ? '/lms/courses' : '/lms/batches'"
			/>
		</div>
		<div v-else-if="!user.data?.name">
			<NotPermitted
				text="Пожалуйста, войдите, чтобы получить доступ к этой странице."
				:buttonLink="`/login?redirect-to=/lms/billing/${type}/${name}`"
			/>
		</div>
	</div>
</template>
<script setup>
import Link from '@/components/Controls/Link.vue'
import NotPermitted from '@/components/NotPermitted.vue'
import { showToast } from '@/utils/'
import { Breadcrumbs, Button, createResource, FormControl } from 'frappe-ui'
import { inject, onMounted, reactive } from 'vue'

const user = inject('$user')

onMounted(() => {
	const script = document.createElement('script')
	script.src = `https://checkout.razorpay.com/v1/checkout.js`
	document.body.appendChild(script)
	if (user.data?.name) {
		access.submit()
	}
})

const props = defineProps({
	type: {
		type: String,
		required: true,
	},
	name: {
		type: String,
		required: true,
	},
})

const access = createResource({
	url: 'lms.lms.api.validate_billing_access',
	params: {
		type: props.type,
		name: props.name,
	},
	onSuccess(data) {
		setBillingDetails(data.address)
		orderSummary.submit()
	},
})

const orderSummary = createResource({
	url: 'lms.lms.utils.get_order_summary',
	makeParams(values) {
		return {
			doctype: props.type == 'course' ? 'LMS Course' : 'LMS Batch',
			docname: props.name,
			country: billingDetails.country,
		}
	},
	onError(err) {
		showError(err)
	},
})

const billingDetails = reactive({})

const setBillingDetails = (data) => {
	billingDetails.billing_name = data?.billing_name || ''
	billingDetails.address_line1 = data?.address_line1 || ''
	billingDetails.address_line2 = data?.address_line2 || ''
	billingDetails.city = data?.city || ''
	billingDetails.state = data?.state || ''
	billingDetails.country = data?.country || ''
	billingDetails.pincode = data?.pincode || ''
	billingDetails.phone = data?.phone || ''
	billingDetails.source = data?.source || ''
	billingDetails.gstin = data?.gstin || ''
	billingDetails.pan = data?.pan || ''
}

const paymentLink = createResource({
	url: 'lms.lms.payments.get_payment_link',
	makeParams(values) {
		return {
			doctype: props.type == 'course' ? 'LMS Course' : 'LMS Batch',
			docname: props.name,
			title: orderSummary.data.title,
			amount: orderSummary.data.original_amount,
			total_amount: orderSummary.data.amount,
			currency: orderSummary.data.currency,
			address: billingDetails,
		}
	},
})

const generatePaymentLink = () => {
	paymentLink.submit(
		{},
		{
			validate() {
				if (!billingDetails.source) {
					return __('Пожалуйста, сообщите нам, откуда вы о нас узнали.')
				}
				return validateAddress()
			},
			onSuccess(data) {
				window.location.href = data
			},
			onError(err) {
				showToast(__('Ошибка'), err.messages?.[0] || err, 'x')
			},
		},
	)
}

const validateAddress = () => {
	let mandatoryFields = [
		'billing_name',
		'address_line1',
		'city',
		'pincode',
		'country',
		'phone',
		'source',
	]
	for (let field of mandatoryFields) {
		if (!billingDetails[field])
			return (
				'Пожалуйста, введите действительный ' +
				field
					.replaceAll('_', ' ')
					.toLowerCase()
					.replace(/\b\w/g, (s) => s.toUpperCase())
			)
	}

	if (billingDetails.gstin && !billingDetails.pan)
		return 'Пожалуйста, введите действительный номер PAN.'

	if (billingDetails.country == 'India' && !billingDetails.state)
		return 'Пожалуйста, введите действительное название штата с правильным написанием и заглавной первой буквой.'

	const states = [
		'Андхра-Прадеш',
		'Аруначал-Прадеш',
		'Ассам',
		'Бихар',
		'Чхаттисгарх',
		'Дели',
		'Гоа',
		'Гуджарат',
		'Харьяна',
		'Химачал-Прадеш',
		'Джаркханд',
		'Карнатака',
		'Керала',
		'Мадхья-Прадеш',
		'Махараштра',
		'Манипур',
		'Мегхалая',
		'Мизорам',
		'Нагаленд',
		'Одиша',
		'Пенджаб',
		'Раджастхан',
		'Сикким',
		'Тамилнад',
		'Телангана',
		'Трипура',
		'Уттар-Прадеш',
		'Уттаракханд',
		'Западная Бенгалия',
	]
	if (
		billingDetails.country == 'India' &&
		!states.includes(billingDetails.state)
	)
		return 'Пожалуйста, введите действительное название штата с правильным написанием и заглавной первой буквой.'
}

const showError = (err) => {
	createToast({
		title: 'Ошибка',
		text: err.messages?.[0] || err,
		icon: 'x',
		iconClasses: 'bg-red-600 text-white rounded-md p-px',
		position: 'top-center',
		timeout: 10,
	})
}

const changeCurrency = (country) => {
	billingDetails.country = country
	orderSummary.reload()
}
</script>
