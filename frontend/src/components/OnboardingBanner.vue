<template>
	<div v-if="showOnboardingBanner && onboardingDetails.data">
		<Tooltip :text="__('Пропустить онбординг')" placement="left">
			<X
				class="absolute w-4 h-4 mr-1 cursor-pointer stroke-1 top-2 right-2"
				@click="skipOnboarding.reload()"
			/>
		</Tooltip>
		<div class="flex items-center p-10 bg-gray-100 justify-evenly">
			<div
				@click="redirectToCourseForm()"
				class="flex items-center space-x-2"
				:class="{
					'cursor-pointer': !onboardingDetails.data.course_created?.length,
				}"
			>
				<span
					v-if="onboardingDetails.data.course_created?.length"
					class="px-1 py-1 bg-white rounded-full"
				>
					<Check class="w-4 h-4 text-green-600 stroke-2" />
				</span>
				<span v-else class="px-2 py-1 font-semibold bg-white rounded-full">
					1
				</span>
				<span class="text-lg font-semibold">
					{{ __('Создать курс') }}
				</span>
			</div>
			<div
				@click="redirectToChapterForm()"
				class="flex items-center space-x-2"
				:class="{
					'cursor-pointer':
						onboardingDetails.data.course_created?.length &&
						!onboardingDetails.data.chapter_created?.length,
					'text-gray-400': !onboardingDetails.data.course_created?.length,
				}"
			>
				<span
					v-if="onboardingDetails.data.chapter_created?.length"
					class="px-1 py-1 bg-white rounded-full"
				>
					<Check class="w-4 h-4 text-green-600 stroke-2" />
				</span>
				<span v-else class="px-2 py-1 font-semibold bg-white rounded-full">
					2
				</span>
				<span class="text-lg font-semibold">
					{{ __('Добавить главу') }}
				</span>
			</div>
			<div
				@click="redirectToLessonForm()"
				class="flex items-center space-x-2"
				:class="{
					'cursor-pointer':
						onboardingDetails.data.course_created?.length &&
						onboardingDetails.data.chapter_created?.length,
					'text-gray-400':
						!onboardingDetails.data.course_created?.length ||
						!onboardingDetails.data.chapter_created?.length,
				}"
			>
				<span
					v-if="onboardingDetails.data.lesson_created?.length"
					class="px-1 py-1 bg-white rounded-full"
				>
					<Check class="w-4 h-4 text-green-600 stroke-2" />
				</span>
				<span class="px-2 py-1 font-semibold bg-white rounded-full"> 3 </span>
				<span class="text-lg font-semibold">
					{{ __('Добавить урок') }}
				</span>
			</div>
		</div>
	</div>
</template>
<script setup lang="ts">
import { useSettings } from '@/stores/settings'
import { createResource, Tooltip } from 'frappe-ui'
import { Check, X } from 'lucide-vue-next'
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const showOnboardingBanner = ref(false)
const settings = useSettings()
const onboardingDetails = settings.onboardingDetails
const router = useRouter()

watch(onboardingDetails, () => {
	if (!onboardingDetails.data?.is_onboarded) {
		showOnboardingBanner.value = true
	} else {
		showOnboardingBanner.value = false
	}
})

const redirectToCourseForm = () => {
	if (onboardingDetails.data?.course_created.length) {
		return
	} else {
		router.push({ name: 'CourseForm', params: { courseName: 'new' } })
	}
}

const redirectToChapterForm = () => {
	if (!onboardingDetails.data?.course_created.length) {
		return
	} else {
		router.push({
			name: 'CourseForm',
			params: {
				courseName: onboardingDetails.data?.first_course,
			},
		})
	}
}

const redirectToLessonForm = () => {
	if (!onboardingDetails.data?.course_created.length) {
		return
	} else if (!onboardingDetails.data?.chapter_created.length) {
		return
	} else {
		router.push({
			name: 'LessonForm',
			params: {
				courseName: onboardingDetails.data?.first_course,
				chapterNumber: 1,
				lessonNumber: 1,
			},
		})
	}
}

const skipOnboarding = createResource({
	url: 'frappe.client.set_value',
	makeParams() {
		return {
			doctype: 'LMS Settings',
			name: 'LMS Settings',
			fieldname: 'is_onboarding_complete',
			value: 1,
		}
	},
	onSuccess(data) {
		onboardingDetails.reload()
	},
})
</script>
