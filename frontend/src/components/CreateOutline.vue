<template>
	<div v-if="course">
		<div class="text-xl font-semibold">
			{{ course.title }}
		</div>
		<div v-if="course.chapters.length">
			{{ course.chapters }}
		</div>
		<div v-else class="p-5 mt-4 text-center bg-white border rounded-md">
			<div>
				{{
					__('В этом курсе нет глав. Создавайте и управляйте главами здесь.')
				}}
			</div>
			<Button class="mt-4">
				{{ __('Добавить главу') }}
			</Button>
		</div>
	</div>
</template>
<script setup>
const props = defineProps({
	course: {
		type: Object,
		default: {},
	},
})
</script>
