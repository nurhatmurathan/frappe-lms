<template>
	<div class="mb-10 mt-7">
		<h2 class="mb-3 text-lg font-semibold text-gray-900">
			{{ __('Сертификаты') }}
		</h2>
		<div class="grid gap-4 grod-cols-1 md:grid-cols-2 lg:grid-cols-3">
			<div
				v-for="certificate in certificates.data"
				:key="certificate.name"
				class="p-3 bg-white rounded-lg shadow cursor-pointer"
				@click="openCertificate(certificate)"
			>
				<div class="font-medium leading-5">
					{{ certificate.course_title }}
				</div>
				<div class="mt-2">
					<span class="text-xs text-gray-700"> {{ __('выдан') }}: </span>
					{{ dayjs(certificate.issue_date).format('DD MMM YYYY') }}
				</div>
			</div>
		</div>
	</div>
</template>
<script setup>
import { createResource } from 'frappe-ui'
import { inject } from 'vue'

const dayjs = inject('$dayjs')
const props = defineProps({
	profile: {
		type: Object,
		required: true,
	},
})

const certificates = createResource({
	url: 'lms.lms.api.get_certificates',
	params: {
		member: props.profile.data.name,
	},
	auto: true,
})

const openCertificate = (certificate) => {
	window.open(
		`/api/method/frappe.utils.print_format.download_pdf?doctype=LMS+Certificate&name=${
			certificate.name
		}&format=${encodeURIComponent(certificate.template)}`,
	)
}
</script>
