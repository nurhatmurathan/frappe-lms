<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadbrumbs" />
		<Button
			v-if="user.data?.is_moderator || user.data?.is_instructor"
			@click="showDialog = true"
			variant="solid"
		>
			<template #prefix>
				<Plus class="h-4 w-4 stroke-1.5" />
			</template>
			{{ __('Новый') }}
		</Button>
	</header>
	<div v-if="programs.data?.length" class="px-5 pt-5">
		<div v-for="program in programs.data" class="mb-10">
			<div class="flex items-center justify-between">
				<div class="text-xl font-semibold">
					{{ program.name }}
				</div>
				<div class="flex items-center space-x-2">
					<Badge
						v-if="program.members"
						variant="subtle"
						theme="green"
						size="lg"
					>
						{{ program.members }}
						{{
							program.members == 1
								? __(singularize('участник'))
								: __('участников')
						}}
					</Badge>
					<Badge
						v-if="program.progress"
						variant="subtle"
						theme="blue"
						size="lg"
					>
						{{ program.progress }}{{ __('% завершено') }}
					</Badge>

					<router-link
						v-if="user.data?.is_moderator || user.data?.is_instructor"
						:to="{
							name: 'ProgramForm',
							params: { programName: program.name },
						}"
					>
						<Button>
							<template #prefix>
								<Edit class="h-4 w-4 stroke-1.5" />
							</template>
							{{ __('Редактировать') }}
						</Button>
					</router-link>
				</div>
			</div>
			<div
				v-if="program.courses?.length"
				class="grid grid-cols-1 gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3"
			>
				<div v-for="course in program.courses" class="relative group">
					<CourseCard
						:course="course"
						@click="enrollMember(program.name, course.name)"
						class="cursor-pointer"
					/>
					<div
						v-if="lockCourse(course)"
						class="absolute inset-0 rounded-md bg-black-overlay-500 opacity-60"
					></div>
					<div
						v-if="lockCourse(course)"
						class="absolute inset-0 flex items-center justify-center"
					>
						<LockKeyhole class="text-white size-10" />
					</div>
				</div>
			</div>
			<div v-else class="mt-4 text-sm italic text-gray-600">
				{{ __('В этой программе нет курсов') }}
			</div>
		</div>
	</div>
	<div
		v-else
		class="w-3/4 p-5 mx-auto space-y-2 text-center text-gray-600 mt-52 md:w-1/2"
	>
		<BookOpen class="mx-auto text-gray-500 stroke-1 size-10" />
		<div class="text-xl font-medium">
			{{ __('Программы не найдены') }}
		</div>
		<div class="leading-5">
			{{
				__(
					'В данный момент нет доступных программ. Следите за обновлениями, скоро появятся новые возможности для обучения!',
				)
			}}
		</div>
	</div>

	<Dialog
		v-model="showDialog"
		:options="{
			title: __('Новая программа'),
			actions: [
				{
					label: __('Создать'),
					variant: 'solid',
					onClick: () => createProgram(close),
				},
			],
		}"
	>
		<template #body-content>
			<FormControl :label="__('Название')" v-model="title" />
		</template>
	</Dialog>
</template>
<script setup>
import CourseCard from '@/components/CourseCard.vue'
import { useSettings } from '@/stores/settings'
import { showToast, singularize } from '@/utils'
import {
	Badge,
	Breadcrumbs,
	Button,
	call,
	createResource,
	Dialog,
	FormControl,
} from 'frappe-ui'
import { BookOpen, Edit, LockKeyhole, Plus } from 'lucide-vue-next'
import { computed, inject, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

const user = inject('$user')
const showDialog = ref(false)
const router = useRouter()
const title = ref('')
const settings = useSettings()

onMounted(() => {
	if (
		!settings.learningPaths.data &&
		!user.data?.is_moderator &&
		!user.data?.is_instructor
	) {
		router.push({ name: 'Courses' })
	}
})

const programs = createResource({
	url: 'lms.lms.utils.get_programs',
	auto: true,
	cache: 'programs',
})

const createProgram = (close) => {
	call('frappe.client.insert', {
		doc: {
			doctype: 'LMS Program',
			title: title.value,
		},
	}).then((res) => {
		router.push({ name: 'ProgramForm', params: { programName: res.name } })
	})
}

const enrollMember = (program, course) => {
	call('lms.lms.utils.enroll_in_program_course', {
		program: program,
		course: course,
	})
		.then((data) => {
			if (data.current_lesson) {
				router.push({
					name: 'Lesson',
					params: {
						courseName: course,
						chapterNumber: data.current_lesson.split('-')[0],
						lessonNumber: data.current_lesson.split('-')[1],
					},
				})
			} else if (data) {
				router.push({
					name: 'Lesson',
					params: {
						courseName: course,
						chapterNumber: 1,
						lessonNumber: 1,
					},
				})
			}
		})
		.catch((err) => {
			showToast('Ошибка', err.messages?.[0] || err, 'x')
		})
}

const lockCourse = (course) => {
	if (user.data?.is_moderator || user.data?.is_instructor) return false
	if (course.membership) return false
	if (course.eligible) return false
	return true
}

const breadbrumbs = computed(() => [
	{
		label: 'Программы',
	},
])
</script>
