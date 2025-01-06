<template>
	<div class="w-1/3 mx-auto my-32 text-base border rounded-md">
		<div class="px-5 py-3 font-medium border-b">
			<span
				class="inline-flex items-center before:bg-red-600 before:w-2 before:h-2 before:rounded-md before:mr-2"
			></span>
			{{ __('Недопустимо') }}
		</div>
		<div class="px-5 py-3">
			<div class="mb-4 leading-6">
				{{ __('Вам не разрешено посещать эту страницу.') }}
			</div>
			<Button variant="solid" class="w-full" @click="redirect()">
				{{ __('Войти') }}
			</Button>
		</div>
	</div>
</template>
<script setup>
import { Button } from 'frappe-ui'

const props = defineProps({
	title: {
		type: String,
		default: 'Not Permitted',
	},
	text: {
		type: String,
		default: 'You are not permitted to access this page.',
	},
	buttonLabel: {
		type: String,
		default: 'Login',
	},
	buttonLink: {
		type: String,
		default: '/login',
	},
})

const redirect = () => {
	window.location.href = props.buttonLink
}
</script>
