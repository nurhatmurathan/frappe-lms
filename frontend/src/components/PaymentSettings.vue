<template>
	<div class="flex flex-col h-full">
		<div class="flex items-center justify-between">
			<div class="mb-1 text-xl font-semibold">
				{{ label }}
			</div>
			<!-- <Badge
				v-if="isDirty"
				:label="__('Не сохранено')"
				variant="subtle"
				theme="orange"
			/> -->
		</div>
		<div class="overflow-y-scroll">
			<div class="flex space-x-4">
				<SettingFields :fields="fields" :data="data.doc" class="w-1/2" />
				<SettingFields
					v-if="paymentGateway.data"
					:fields="paymentGateway.data.fields"
					:data="paymentGateway.data.data"
					class="w-1/2"
				/>
			</div>
		</div>
		<div class="flex flex-row-reverse mt-auto">
			<Button variant="solid" @click="update">
				{{ __('Обновить') }}
			</Button>
		</div>
	</div>
</template>
<script setup>
import SettingFields from '@/components/SettingFields.vue'
import { Button, createResource } from 'frappe-ui'
import { watch } from 'vue'

const props = defineProps({
	label: {
		type: String,
		required: true,
	},
	description: {
		type: String,
		required: true,
	},
	data: {
		type: Object,
		required: true,
	},
	fields: {
		type: Array,
		required: true,
	},
})

const paymentGateway = createResource({
	url: 'lms.lms.api.get_payment_gateway_details',
	makeParams(values) {
		return {
			payment_gateway: props.data.doc.payment_gateway,
		}
	},
	auto: true,
})

const saveSettings = createResource({
	url: 'frappe.client.set_value',
	makeParams(values) {
		let fields = {}
		Object.keys(paymentGateway.data.data).forEach((key) => {
			if (
				paymentGateway.data.data[key] &&
				typeof paymentGateway.data.data[key] === 'object'
			) {
				fields[key] = paymentGateway.data.data[key].file_url
			} else {
				fields[key] = paymentGateway.data.data[key]
			}
		})

		return {
			doctype: paymentGateway.data.doctype,
			name: paymentGateway.data.docname,
			fieldname: fields,
		}
	},
	auto: false,
	onSuccess(data) {
		paymentGateway.reload()
	},
})

const update = () => {
	props.fields.forEach((f) => {
		if (f.type != 'Column Break') {
			props.data.doc[f.name] = f.value
		}
	})
	props.data.save.submit()
	saveSettings.submit()
}

watch(
	() => props.data.doc.payment_gateway,
	() => {
		paymentGateway.reload()
	},
)
</script>
