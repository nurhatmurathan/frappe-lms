<template>
	<Assignment
		v-if="user.data && submission.data"
		:assignmentID="assignmentID"
		:submissionName="submission.data?.name || 'новый'"
	/>
	<div v-else class="py-20 text-center border rounded-md">
		<div>
			{{ __('Пожалуйста, войдите, чтобы получить доступ к заданию.') }}
		</div>
		<Button @click="redirectToLogin()" class="mt-2">
			<span>
				{{ __('Войти') }}
			</span>
		</Button>
	</div>
</template>
<script setup>
import Assignment from '@/components/Assignment.vue'
import { Button, createResource } from 'frappe-ui'
import { inject } from 'vue'

const user = inject('$user')

const props = defineProps({
	assignmentID: {
		type: String,
		required: true,
	},
})

const submission = createResource({
	url: 'frappe.client.get_value',
	makeParams(values) {
		return {
			doctype: 'LMS Assignment Submission',
			fieldname: 'name',
			filters: {
				assignment: props.assignmentID,
				member: user.data?.name,
			},
		}
	},
	auto: true,
})
</script>
